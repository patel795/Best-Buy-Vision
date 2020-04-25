//
//  ProoductsTableViewController.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-04-14.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProoductsTableViewController: UITableViewController {

    let APIKEY = "TWVhgdNpaxCG1GSk4IReKegI"
    var productNameString = ""
    var products =  [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 115
        makeApiCall()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    private func makeApiCall(){
        let startingText = "search="
        productNameString = startingText + productNameString
        productNameString = productNameString.replacingOccurrences(of: " ", with: "&search=", options: .literal, range: nil)
        
        let URL = "https://api.bestbuy.com/v1/products((\(productNameString)&active=true))?format=json&sort=bestSellingRank.asc&show=sku,name,salePrice,bestSellingRank,image,shortDescription&pageSize=100&apiKey=\(APIKEY)"
        print(URL)
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
            (response) in
            
            if (response.result.isSuccess) {
                do {
                        let json = try JSON(data:response.data!)
                        for i in 0...json["products"].count{
                        var item = Product(productName: json["products"][i]["name"].stringValue,
                                           productPrice: json["products"][i]["salePrice"].stringValue,
                                           productDescription: json["products"][i]["shortDescription"].stringValue,
                                           SKU: json["products"][i]["sku"].stringValue,
                                           productThumbnailURL: json["products"][i]["image"].stringValue)
                        self.products.append(item)
                    }
                    self.tableView.reloadData()
                }
                catch {
                    print ("Error while parsing JSON response")
                }
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
        return products.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductList", for: indexPath) as! ProductTableViewCell
        var image = UIImage()
        let url = NSURL(string: self.products[indexPath.row].productThumbnailURL)
        if(url?.absoluteString != ""){
            let data = NSData(contentsOf : url as! URL)
            image = UIImage(data : data! as Data)!
        }
        else{
            image = UIImage(named: "questionmark.png")!;
        }
        cell.productImage.image = image
        cell.productName?.text = self.products[indexPath.row].productName
        cell.productPrice?.text = "$" + self.products[indexPath.row].productPrice
        
        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
