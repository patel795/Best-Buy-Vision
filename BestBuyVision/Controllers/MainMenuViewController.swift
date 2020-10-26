//
//  MainMenuViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-10-02.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Firebase

class MainMenuViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    var imageArray = [UIImage(named : "Bacwardslcon"), UIImage(named : "ImageRecognitionLogo"), UIImage(named : "iphone_product_image"), UIImage(named : "Logo"), UIImage(named : "Logo2")]
    
    let db = Firestore.firestore()
    private var apiHandler = ApiHandlers()
    var products =  [Product]()
    let cardViewForTextRecognition = CardsUIView()
    let cardViewForImageRecognition = CardsUIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        getDataFromFirebase()
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
        let backButtonImage = UIImage(systemName: "arrow.left")
        let backBtn = UIButton(type: .system)
        backBtn.setImage(backButtonImage, for: .normal)
        backBtn.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        backBtn.imageView?.contentMode = .scaleAspectFit
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = false
        
        let image = UIImage(named: "Logo2")
        let newImage = image?.imageWithColor(.white)
        var titleViewImage = UIImageView()
        titleViewImage = UIImageView(image: newImage?.imageWithInsets(insets: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)))
        titleViewImage.contentMode = .scaleAspectFit
        
        tabBarController?.navigationItem.titleView = titleViewImage
        
        let accountImage = UIImage(systemName: "person.circle")
        
        let bestbuyBtn = UIButton(type: .system)
        bestbuyBtn.setImage(accountImage, for: .normal)
        bestbuyBtn.imageView?.contentMode = .scaleAspectFit
        bestbuyBtn.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bestbuyBtn)
    }
    
    private func getDataFromFirebase(){
        var firebaseData = [String: Any]()
        
        let group = DispatchGroup()
        
        group.enter()
        self.db.collection("Wishlist").getDocuments() {
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
                let skuArray:[String] = firebaseData["SKU"] as! [String]
                if(!skuArray.isEmpty){
                    self.getProducts(skuArray: skuArray)
                }
            }
        }
    }
    
    private func getProducts(skuArray:[String]){
        let dispatchGroup = DispatchGroup()
        
        for sku in skuArray {
            dispatchGroup.enter()
            apiHandler.makeApiCall(productName: "", sku: Int(sku)!){ (info) in
                self.products = info
                //self.tableView.reloadData()
            }
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        
        //var image = UIImage()
        //let url = NSURL(string: self.products[indexPath.row].productThumbnailURL)
        
        /*if(url?.absoluteString != ""){
            let data = NSData(contentsOf : url! as URL)
            image = UIImage(data : data! as Data)!
        }
        else{
            image = UIImage(named: "Logo")!;
        }*/
        // Configure the cell...
        //cell.productImage.image = image
        //cell.productName.text = self.products[indexPath.row].productName
        //cell.productPrice.text = "$\(self.products[indexPath.row].productPrice)"
        
        cell.productImage.image = imageArray[indexPath.row]
        
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
