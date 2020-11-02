//
//  MainMenuViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-10-02.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class MainMenuViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionViewData: UICollectionView!
    var imageArray = [UIImage(named : "Bacwardslcon"), UIImage(named : "ImageRecognitionLogo"), UIImage(named : "iphone_product_image"), UIImage(named : "Logo"), UIImage(named : "Logo2")]
        
    let db = Firestore.firestore()
    private var apiHandler = ApiHandlers()
    var products =  [Product]()
    var skuArray:[String] = []
    var recommendedProducts = [ProductRecommended]()
    let cardViewForTextRecognition = CardsUIView()
    let cardViewForImageRecognition = CardsUIView()
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromFirebase(dataStorage: "Wishlist")
        getDataFromFirebase(dataStorage: "SearchHistory")
        let cardUiView = cardViewForTextRecognition.getChildView()
        let cardUiViewForImageRecognition = cardViewForImageRecognition.getChildView()
        
        let card1 = cardViewForTextRecognition.createSubView(mainView: view, headerLabel: "Image Recognition", x_coordinate: Double(UIScreen.main.bounds.width * 0.05), y_coordinate: Double(30), forMainMenuLogo: true, imageName: "ImageRecognitionLogo")
        
        let card2 = cardViewForImageRecognition.createSubView(mainView: view, headerLabel: "Text recognition", x_coordinate: Double((UIScreen.main.bounds.width * 0.55)), y_coordinate: Double(30), forMainMenuLogo: true, imageName: "TextRecognitionLogo")
        
        view.addSubview(card1)
        view.addSubview(card2)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickImageRecognitionImageView(_:)))
        tapGesture.delegate = self
        cardUiView.addGestureRecognizer(tapGesture)
        
        let tapGestureForCard2 = UITapGestureRecognizer(target: self, action: #selector(clickTextRecognitionImageView(_:)))
        tapGestureForCard2.delegate = self
        cardUiViewForImageRecognition.addGestureRecognizer(tapGestureForCard2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.hidesBackButton = true
        setUpNavigationBar()
    }
    
    @objc func clickImageRecognitionImageView(_ sender: UIView) {
        performSegue(withIdentifier: "segueImageRecognition", sender: nil)
    }
    
    @objc func clickTextRecognitionImageView(_ sender: UIView) {
        performSegue(withIdentifier: "segueTextRecognition", sender: nil)
    }
    
    private func setUpNavigationBar() {
        
        /*
        let backButtonImage = UIImage(systemName: "arrow.left")
        let backBtn = UIButton(type: .system)
        backBtn.setImage(backButtonImage, for: .normal)
        backBtn.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        backBtn.imageView?.contentMode = .scaleAspectFit
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = false
        */
        
        let image = UIImage(named: "Logo2")
        let newImage = image?.imageWithColor(.white)
        var titleViewImage = UIImageView()
        titleViewImage = UIImageView(image: newImage?.imageWithInsets(insets: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)))
        titleViewImage.contentMode = .scaleAspectFit
        
        tabBarController?.navigationItem.titleView = titleViewImage
        
        /*
        let accountImage = UIImage(systemName: "person.circle")
        
        let bestbuyBtn = UIButton(type: .system)
        bestbuyBtn.setImage(accountImage, for: .normal)
        bestbuyBtn.imageView?.contentMode = .scaleAspectFit
        bestbuyBtn.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bestbuyBtn)
        */
    }
        
    private func getDataFromFirebase(dataStorage:String){
        var firebaseData = [String: Any]()
        
        let group = DispatchGroup()
        
        group.enter()
        self.db.collection(dataStorage).getDocuments() {
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
                let sku:[String] = firebaseData["SKU"] as! [String]
                var counter = 0
                if(!sku.isEmpty){
                    //self.getProducts(skuArray: skuArray)
                    if(sku.count >= 3){
                        while (counter < 3) {
                            let randomSKU = sku.randomElement()
                            if(self.skuArray.contains(randomSKU!)){
                                print("Do nothing")
                            }
                            else{
                                self.skuArray.append(randomSKU!)
                                counter+=1
                            }
                        }
                    }
                    else{
                        self.skuArray.append(contentsOf: sku)
                    }
                    
                    if(self.count == 1){
                        print("Hello", self.skuArray)
                        self.getProducts(skuArray: self.skuArray)
                    }
                    self.count+=1
                }
            }
        }
    }
    
    private func getProducts(skuArray:[String]){
        let dispatchGroup = DispatchGroup()
        
        for sku in skuArray {
            dispatchGroup.enter()
            apiHandler.makeMostViewedProductApiCall(productName: "", sku: Int(sku)!){ (info) in
                self.recommendedProducts = info
                //self.tableView.reloadData()
                self.collectionViewData.reloadData()
                //self.collectionViewData.reloadItems(at: self.items)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recommendedProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        
        var image = UIImage()
        let url = NSURL(string: self.recommendedProducts[indexPath.row].productThumbnailURL)
        
        if(url?.absoluteString != ""){
            let data = NSData(contentsOf : url! as URL)
            image = UIImage(data : data! as Data)!
        }
        else{
            image = UIImage(named: "Logo")!;
        }
        // Configure the cell...
        cell.productImage.image = image
        cell.productName.text = self.recommendedProducts[indexPath.row].productName
        cell.productPrice.text = "$\(self.recommendedProducts[indexPath.row].productPrice)"
        
        let ratingNumber = Double(self.recommendedProducts[indexPath.row].averageScore )
        let starView: CosmosView = {
            let view  = CosmosView()
            view.settings.updateOnTouch = false
            view.rating = ratingNumber ?? 0
            view.settings.fillMode = .precise
            return view
        }()
        cell.productReview.addSubview(starView)
        
        //self.collectionView.reloadData()
        //cell.productImage.image = imageArray[indexPath.row]
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    }

