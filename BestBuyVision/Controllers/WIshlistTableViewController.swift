//
//  WIshlistTableViewController.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-10-18.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Firebase

class WIshlistTableViewController: UITableViewController {

    let db = Firestore.firestore()
    private var apiHandler = ApiHandlers()
    var products =  [Product]()
    var indexPathRow = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.tableView.reloadData()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        
        
        tableView.rowHeight = 130
        navigationItem.title = "Wishlist Products"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = Colors.bestBuyBlue
        navigationController?.navigationBar.barTintColor = Colors.bestBuyBlue
        navigationController?.navigationBar.tintColor = Colors.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        self.showSpinner(onView: self.view)
        
        //get data
        getDataFromFirebase()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func refresh(sender:AnyObject) {
        getDataFromFirebase()
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
            else{
                self.removeSpinner()
                self.products = []
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            }
        }
    }

    private func getProducts(skuArray:[String]){
        let dispatchGroup = DispatchGroup()
        let apiHandler = ApiHandlers()
        products = [Product]()
        var arrayString = ""
        for sku in skuArray{
            if(arrayString == ""){
                arrayString = "\(sku)"
            }
            else{
                arrayString = "\(arrayString),\(sku)"
            }
        }
        print(arrayString)
        dispatchGroup.enter()
        apiHandler.makeBatchApiCall(skus: arrayString){ (info) in
            self.products = info
            self.tableView.reloadData()
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            self.removeSpinner()
            self.refreshControl!.endRefreshing()
        }
    }
    // MARK: - Table view data source

    @IBAction func deleteAll(_ sender: Any) {
        let alert = UIAlertController(title: "Delete All", message: "Are you sure you want to delete all wishlist products?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                do {
                    print(Auth.auth().currentUser!.uid)
                    self.db.collection("Wishlist").document("\(Auth.auth().currentUser!.uid)").updateData(["SKU" : FieldValue.delete()])
                    self.getDataFromFirebase()
                    } catch let err {
                        print(err)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.products.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishlistCell", for: indexPath) as! WishlistTableViewCell

        var image = UIImage()
        let url = NSURL(string: self.products[indexPath.row].productThumbnailURL)
        
        if(url?.absoluteString != ""){
            let data = NSData(contentsOf : url! as URL)
            image = UIImage(data : data! as Data)!
        }
        else{
            image = UIImage(named: "Logo")!;
        }
        // Configure the cell...
        cell.wishlistProductImage.image = image
        cell.wishlistProductName.text = self.products[indexPath.row].productName
        let convertedPrice = Double("\(self.products[indexPath.row].productPrice)")
        cell.wishlistProductPrice?.text = String(format: "$%.2f", convertedPrice as! Double)
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView .beginUpdates()
            db.collection("Wishlist").document("\(Auth.auth().currentUser!.uid)").updateData(["SKU" : FieldValue.arrayRemove(["\(self.products[indexPath.row].SKU)"])])
            self.products.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView .endUpdates()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        indexPathRow = indexPath.row
        self.performSegue(withIdentifier: "segueWishlistProductDetail", sender: AnyObject?.self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueWishlistProductDetail" {
            if let productDescriptionDetailController = segue.destination as? ProductDescriptionTableViewController {
                productDescriptionDetailController.SKU = products[indexPathRow].SKU
            }
        }
    }

}
