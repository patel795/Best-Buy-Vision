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
    var productName =  [String]()
    var productPrice = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Hello", productNameString)
        makeApiCall()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    private func makeApiCall(){
        let startingText = "search="
        //let searchText = productName.text!
        //var productNameString = productName.text!
        productNameString = startingText + productNameString
        productNameString = productNameString.replacingOccurrences(of: " ", with: "&search=", options: .literal, range: nil)
        
        /*
        var textFinal = searchText.components(separatedBy: " ").first
        let secondWord = searchText.components(separatedBy: " ")[1] as String
        textFinal = "\(textFinal!) " + "\(secondWord)"
        textFinal = textFinal!.replacingOccurrences(of: " ", with: "%20")
        */
        //https://api.bestbuy.com/v1/products((\(productNameString))&categoryPath.name=\(textFinal!)*)?format=json&show=sku,name,salePrice&apiKey=\(APIKEY)
        let URL = "https://api.bestbuy.com/v1/products((\(productNameString)))?format=json&sort=bestSellingRank.asc&show=sku,name,salePrice,bestSellingRank&pageSize=100&apiKey=\(APIKEY)"
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
            (response) in
            
            // -- put your code below this line
            
            if (response.result.isSuccess) {
                print("awesome, i got a response from the website!")
                
                do {
                    let json = try JSON(data:response.data!)
                    for i in 0...json["products"].count{
                        self.productName.append(json["products"][i]["name"].stringValue)
                        self.productPrice.append(json["products"][i]["salePrice"].stringValue)
                    }
                    //print(json)
                    //print(self.productName)
                    //print(self.productPrice)
                    self.tableView.reloadData()
                    //print(json)
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
        return productName.count - 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductList", for: indexPath)
        
        //let price = String(format:"%.2f", self.productPrice[indexPath.row])
        //print(String(format:"%.2f", price))
        cell.textLabel?.text = self.productName[indexPath.row];
        cell.detailTextLabel?.text = "Price: " + self.productPrice[indexPath.row]
        // Configure the cell...

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
