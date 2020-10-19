//
//  ProductDescriptionDetailControllerViewController.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-04-30.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ImageSlideshow
import Firebase

class ProductDescriptionDetailControllerViewController: UIViewController, ImageSlideshowDelegate{
    
    let APIKEY = "TWVhgdNpaxCG1GSk4IReKegI"
    var SKU = ""
    var indexPathRow = Int()
    var imageLinks: Array<String> = Array()
    var products =  [Product]()
    var imagesJson: JSON?
    
    @IBOutlet weak var googleReviewBtn: UIButton!
    @IBOutlet weak var expandDescriptionBtn: UIButton!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    var alamofireSource = [AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleReviewBtn.layer.cornerRadius = googleReviewBtn.frame.size.height/2
        
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
            
            self.productName.text = self.products[0].productName
            self.productPrice.text = "$" + self.products[0].productPrice
            self.productDescription.text = self.products[0].productDescription
        }
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
    }
    
    private func imageSlideView(){

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

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ProductDescriptionDetailControllerViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)
    }
    
    @objc func didTap() {
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        
    }
    
    // MARK: - Making API call
    private func makeApiCall(completion: @escaping (String) -> ()){
        
        guard let URL = URL(string:
            "https://api.bestbuy.com/v1/products(sku=\(self.SKU))?show=sku,name,salePrice,images,longDescription&apiKey=\(self.APIKEY)&format=json")
            
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
                                               productThumbnailURL: json["products"][0]["image"].stringValue)
                        
                        self.imagesJson = json["products"][0]["images"]
                        self.products.append(item)
                        
                        DispatchQueue.main.async {
                            //reloading the table view data
                            //self.tableView.reloadData()
                            self.imageSlideView()
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
    
    @IBAction func expandDescriptionClick(_ sender: Any) {
        if(expandDescriptionBtn.titleLabel?.text == "More..."){
            expandDescriptionBtn.setTitle("Less...", for: .normal)
            productDescription.numberOfLines = 0
            productDescription.lineBreakMode = .byWordWrapping
        }
        else if(expandDescriptionBtn.titleLabel?.text == "Less..."){
            expandDescriptionBtn.setTitle("More...", for: .normal)
            productDescription.numberOfLines = 7
            productDescription.lineBreakMode = .byTruncatingTail
        }
    }
    
    @IBAction func googleReviewBtnClick(_ sender: Any) {
        performSegue(withIdentifier: "segueReview", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let googleReviewController = segue.destination as? GoogleReviewTableViewController {
            googleReviewController.productName = self.products[0].productName
        }
    }

}
