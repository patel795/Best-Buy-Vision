//
//  SearchHistoryTableViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-10-18.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SearchHistoryTableViewController: UITableViewController {

    let db = Firestore.firestore()
    var products =  [Product]()
    var indexPathRow = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        
        
        tableView.rowHeight = 130
        /*
        tabBarController?.navigationItem.title = "Search History"
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        tabBarController?.navigationController?.navigationBar.backgroundColor = Colors.bestBuyBlue
        tabBarController?.navigationController?.navigationBar.barTintColor = Colors.bestBuyBlue
        tabBarController?.navigationController?.navigationBar.tintColor = Colors.bestBuyBlue
        tabBarController?.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
         */
        
        
        navigationItem.title = "Search History"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = Colors.bestBuyBlue
        navigationController?.navigationBar.barTintColor = Colors.bestBuyBlue
        navigationController?.navigationBar.tintColor = Colors.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        self.showSpinner(onView: self.view)
        
        //get data
        getDataFromFirebase()
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        getDataFromFirebase()
    }
    */
    
    @objc func refresh(sender:AnyObject) {
        getDataFromFirebase()
    }
    
    private func getDataFromFirebase(){
        var firebaseData = [String: Any]()
        
        let group = DispatchGroup()
        group.enter()
        self.db.collection("SearchHistory").getDocuments() {
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.products.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchHistoryCell", for: indexPath) as! SearchHistoryTableViewCell

        var image = UIImage()
        if(!self.products.isEmpty){
            let url = NSURL(string: self.products[indexPath.row].productThumbnailURL)
            
            if(url?.absoluteString != ""){
                let data = NSData(contentsOf : url! as URL)
                image = UIImage(data : data! as Data)!
            }
            else{
                image = UIImage(named: "Logo")!;
            }
            // Configure the cell...
            cell.searchHistoryImage.image = image
            cell.searchHistoryProductName.text = self.products[indexPath.row].productName
            cell.searchHistoryProductPrice.text = "$\(self.products[indexPath.row].productPrice)"

            return cell
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView .beginUpdates()
            db.collection("SearchHistory").document("\(Auth.auth().currentUser!.uid)").updateData(["SKU" : FieldValue.arrayRemove(["\(self.products[indexPath.row].SKU)"])])
            self.products.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView .endUpdates()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        indexPathRow = indexPath.row
        self.performSegue(withIdentifier: "segueSearchHistory", sender: AnyObject?.self)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueSearchHistory" {
            if let productDescriptionDetailController = segue.destination as? ProductDescriptionTableViewController {
                productDescriptionDetailController.SKU = products[indexPathRow].SKU
            }
        }
    }
}
