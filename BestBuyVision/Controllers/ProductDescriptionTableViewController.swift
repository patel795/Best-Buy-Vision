//
//  ProductDescriptionTableViewController.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-11-10.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ImageSlideshow
import Firebase
import FirebaseAuth

class ProductDescriptionTableViewController: UITableViewController, ImageSlideshowDelegate {

    let APIKEY = "TWVhgdNpaxCG1GSk4IReKegI"
    var SKU = ""
    var indexPathRow = Int()
    var imageLinks: Array<String> = Array()
    var products =  [Product]()
    var imagesJson: JSON?
    var itemBrand = ""
    var temporaryslideshow:ImageSlideshow?
    var productCategory = ""
    
    
    var alamofireSource = [AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
    
    let db = Firestore.firestore()
    let increment = Firebase.FieldValue.increment(1.00)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.saveSearchHistory()
        
        makeApiCall(){ (info) in
            self.alamofireSource.removeAll()
            
            for i in 0...((self.imagesJson?.count ?? 1)-1) {
                let string = self.imagesJson?[i]["rel"].stringValue
                if (string?.contains("Standard"))! {
                    self.alamofireSource.append(AlamofireSource(urlString: (self.imagesJson?[i]["href"].stringValue)!)!)
                    
                }
                //self.imageLinks.append(json["products"][0]["images"][i]["href"].stringValue)
            }
            
            print(self.alamofireSource)
            /*self.productName.text = self.products[0].productName
            self.productPrice.text = "$" + self.products[0].productPrice
            self.productDescription.text = self.products[0].productDescription*/
            
            self.logEvent()
            self.tableView.reloadData()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func logEvent(){
        calculateAverageRating(){ (info) in
            let range = self.priceRangeCalculator(productPrice: Double(self.products[0].productPrice)!)
            let batch = self.db.batch()
            let removedChar: Set<Character> = [".", "/", "\\"]
            self.products[0].manufacturer.removeAll(where: { removedChar.contains($0) })
            self.productCategory.removeAll(where: { removedChar.contains($0) })
            
            let customerDataAnalytics = self.db.collection("CustomerDataAnalytics").document("\(Auth.auth().currentUser!.uid)")
            batch.updateData([self.products[0].manufacturer: info], forDocument: customerDataAnalytics)
            
            let priceRangeSearchHistory = self.db.collection("LoggedEvents").document("price_range_search_history")
            batch.updateData([range : FieldValue.increment(Int64(1)) ], forDocument: priceRangeSearchHistory)

            let mostViewedComapany = self.db.collection("LoggedEvents").document("most_viewed_company")
            batch.updateData([self.products[0].manufacturer: FieldValue.increment(Int64(1)) ], forDocument: mostViewedComapany)
            
            if(self.productCategory != ""){
                let mostViewedCategory = self.db.collection("LoggedEvents").document("most_viewed_category")
                batch.updateData([self.productCategory: FieldValue.increment(Int64(1)) ], forDocument: mostViewedCategory)
            }
            
            // Commit the batch
            batch.commit() { err in
                if let err = err {
                    print("Error writing batch \(err)")
                } else {
                    print("Batch write succeeded.")
                }
            }
        }
    }
    
    private func calculateAverageRating(completion: @escaping (Double) -> ()){
        var firebaseData = [String: Any]()
        let group = DispatchGroup()
        group.enter()
        self.db.collection("CustomerDataAnalytics").getDocuments() {
            (querySnapshot, err) in
            
            // MARK: FB - Boilerplate code to get data from Firestore
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if(document.documentID == Auth.auth().currentUser!.uid){
                        firebaseData = data
                    }
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if(!firebaseData.isEmpty){
                var ratings:Double = firebaseData["\(self.products[0].manufacturer)"] as? Double ?? 0.0
                ratings = (ratings + self.products[0].customerReviewAverage) / 2
                completion(ratings)
            }
        }
    }
    
    private func priceRangeCalculator(productPrice: Double) -> String {
        let priceRangeArray = ["0-250", "250-500", "500-750", "750-1000", "1000-1250", "1250-1500", "1500+"]
        
        for item in priceRangeArray{
            if(item.contains("+")){
                let priceRange = item.components(separatedBy: "+")
                if(productPrice >= Double(priceRange[0])!){
                    return item
                }
            }
            else{
                let priceRange = item.components(separatedBy: "-")
                if(productPrice >= Double(priceRange[0])! && productPrice < Double(priceRange[1])!){
                    return item
                }
            }
        }
        return "ERROR"
    }
    
    private func saveSearchHistory(){
        
        let usersRef = db.collection("SearchHistory").document("\(Auth.auth().currentUser!.uid)")

        usersRef.getDocument { (document, error) in
            if let document = document {

                if document.exists{
                    self.db.collection("SearchHistory").document("\(Auth.auth().currentUser!.uid)").updateData(["SKU" : FieldValue.arrayUnion([self.SKU])])

                } else {
                    self.db.collection("SearchHistory").document("\(Auth.auth().currentUser!.uid)").setData(["SKU" : [self.SKU]])
                }
            }
        }
        
        let daRef = db.collection("CustomerDataAnalytics").document("\(Auth.auth().currentUser!.uid)")

        daRef.getDocument { (document, error) in
            if let document = document {

                if !document.exists{
                    self.db.collection("CustomerDataAnalytics").document("\(Auth.auth().currentUser!.uid)").setData([self.products[0].manufacturer : self.products[0].customerReviewAverage])

                }
            }
        }
    }
    
    private func imageSlideView(slideshow:ImageSlideshow){

        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit

        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        slideshow.pageIndicator = pageControl

        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self

        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow.setImageInputs(alamofireSource)
        temporaryslideshow = slideshow

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ProductDescriptionTableViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)
        //self.tableView.reloadData()
    }
    
    @objc func didTap() {
        let fullScreenController = temporaryslideshow?.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController?.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        
    }
    
    private func makeApiCall(completion: @escaping (String) -> ()){
        
        guard let URL = URL(string:
            "https://api.bestbuy.com/v1/products(sku=\(self.SKU))?show=sku,name,salePrice,images,manufacturer,longDescription,customerReviewAverage&apiKey=\(self.APIKEY)&format=json")
            
        else {
            completion("Error: URL")
            return
        }
        DispatchQueue.main.async {
            //showing loading spinner
            self.showSpinner(onView: self.view)
        }
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
            (response) in
            if (response.result.isSuccess) {
                do {
                    let json = try JSON(data:response.data!)
                    if(json["error"].isEmpty){
                        let item = Product(productName: json["products"][0]["name"].stringValue,
                                               productPrice: json["products"][0]["salePrice"].stringValue,
                                               productDescription: json["products"][0]["longDescription"].stringValue,
                                               SKU: json["products"][0]["sku"].stringValue,
                                               productThumbnailURL: json["products"][0]["image"].stringValue,
                                               manufacturer: json["products"][0]["manufacturer"].stringValue,
                                               customerReviewAverage: json["products"][0]["customerReviewAverage"].doubleValue)
                        
                        self.imagesJson = json["products"][0]["images"]
                        self.products.append(item)
                        
                        DispatchQueue.main.async {
                            //reloading the table view data
                            //self.tableView.reloadData()
                            //self.imageSlideView()
                            self.tableView.reloadData()
                            // remove spinner
                            self.removeSpinner()
                        }
                        
                        completion("Success")
                    }
                    else{
                        self.removeSpinner()
                        self.performSegue(withIdentifier: "segueNoProduct", sender: nil)
                        completion("Can't find the product.")
                    }
                }
                catch {
                    completion("Error while parsing JSON response")
                }
            }
            else{
                // remove spinner
                self.removeSpinner()
                self.performSegue(withIdentifier: "segueNoProduct", sender: nil)
                completion("Request Failed")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productImageCell", for: indexPath)
        if(indexPath.row == 0 && !self.products.isEmpty){
            let cell = tableView.dequeueReusableCell(withIdentifier: "productImageCell", for: indexPath) as! ProductDescriptionImageTableViewCell
            //cell.productDescriptionImageSlideShow = slideshow
            imageSlideView(slideshow: cell.productDescriptionImageSlideShow)
            //cell.productDescriptionImageSlideShow.setImageInputs(alamofireSource)
            //cell.productDescriptionImageSlideShow.setImageInputs(slideshow.images[indexPath])
            cell.productDescriptionProductName.text = self.products[0].productName
            cell.isUserInteractionEnabled = true
            return cell
        }
        else if(indexPath.row == 1 && !self.products.isEmpty){
            let cell = tableView.dequeueReusableCell(withIdentifier: "productPriceCell", for: indexPath) as! ProductDescriptionPriceTableViewCell
            let convertedPrice = Double("\(self.products[0].productPrice)")
            cell.productDescriptionPrice?.text = String(format: "$%.2f", convertedPrice as! Double)
            cell.isUserInteractionEnabled = false
            return cell
        }
        else if(indexPath.row == 2 && !self.products.isEmpty){
            let cell = tableView.dequeueReusableCell(withIdentifier: "productOverviewCell", for: indexPath) as! ProductDescriptionOverviewTableViewCell
            cell.productDescriptionOverview.text = self.products[0].productDescription
            cell.isUserInteractionEnabled = false
            return cell
        }
        else if(indexPath.row == 3 && !self.products.isEmpty){
            let cell = tableView.dequeueReusableCell(withIdentifier: "productSpecificationCell", for: indexPath) as! ProductDescriptionSpecificationTableViewCell
            cell.productDescriptionSpecification.text = "Spefications"
            
            return cell
        }
        else if(indexPath.row == 4 && !self.products.isEmpty){
            let cell = tableView.dequeueReusableCell(withIdentifier: "productGoogleReviewCell", for: indexPath) as! ProductDescriptionGoogleReviewTableViewCell
            cell.productDescriptionGoogleReview.text = "Google Review"
            
            return cell
        }
        // Configure the cell...

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        indexPathRow = indexPath.row
        if(indexPath.row == 4) {
            self.performSegue(withIdentifier: "segueReview", sender: AnyObject?.self)
        }
        if(indexPath.row == 3){
            self.performSegue(withIdentifier: "segueSpecification", sender: nil)
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    @IBAction func addToWishlist(_ sender: Any) {
        let usersRef = db.collection("Wishlist").document("\(Auth.auth().currentUser!.uid)")

        usersRef.getDocument { (document, error) in
            if let document = document {
                if document.exists{
                    self.db.collection("Wishlist").document("\(Auth.auth().currentUser!.uid)").updateData(["SKU" : FieldValue.arrayUnion([self.SKU])])

                } else {
                    self.db.collection("Wishlist").document("\(Auth.auth().currentUser!.uid)").setData(["SKU" : [self.SKU]])
                }
            }
        }
        
        let daRef = db.collection("CustomerDataAnalytics").document("\(Auth.auth().currentUser!.uid)")

        calculateAverageRating(){ (info) in
            daRef.getDocument { (document, error) in
                if let document = document {

                    if document.exists{
                        self.db.collection("CustomerDataAnalytics").document("\(Auth.auth().currentUser!.uid)").updateData([self.products[0].manufacturer : info])
                    }
                    else{
                        self.db.collection("CustomerDataAnalytics").document("\(Auth.auth().currentUser!.uid)").setData([self.products[0].manufacturer : self.products[0].customerReviewAverage])
                    }
                }
            }
        }
        
        MakeToast.showToast(controller: self, message: "Product is added in wishlist", seconds: 1.0)
        addWishListToDataAnalytics()
    }
    
    private func addWishListToDataAnalytics(){
        let range = priceRangeCalculator(productPrice: Double(self.products[0].productPrice)!)
        let batch = db.batch()
        let removedChar: Set<Character> = [".", "/", "\\"]
        self.products[0].manufacturer.removeAll(where: { removedChar.contains($0) })
        
        let priceRangeSearchHistory = db.collection("LoggedEvents").document("price_range_wishlist")
        batch.updateData([range : FieldValue.increment(Int64(1)) ], forDocument: priceRangeSearchHistory)

        let mostViewedComapany = db.collection("LoggedEvents").document("companies_wishlist")
        batch.updateData([self.products[0].manufacturer: FieldValue.increment(Int64(1)) ], forDocument: mostViewedComapany)

        //let laRef = db.collection("cities").document("LA")
        //batch.deleteDocument(laRef)
        
        // Commit the batch
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueReview" {
            if let googleReviewController = segue.destination as? GoogleReviewTableViewController {
                googleReviewController.productName = self.products[0].productName
            }
        }
        if segue.identifier == "segueSpecification" {
            if let googleReviewController = segue.destination as? ProductSpeficationTableViewController {
                googleReviewController.sku = self.products[0].SKU
            }
        }
    }
}
