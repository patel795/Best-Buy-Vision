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
    var productNameStrings: Array<String> = Array()
    var products =  [Product]()
    var indexPathRow = Int()
    
    @IBOutlet weak var productNames: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 115
        var formattedProductNames = "*For debugging purposes only* \n"
        for i in 0...1{
            formattedProductNames = formattedProductNames + productNameStrings[i] + "\n"
        }
        productNames.text = "\(formattedProductNames)"
        
        let group = DispatchGroup()
        
        for index in 0...(productNameStrings.count - 1) {
            group.enter()
            makeApiCall(productName: productNameStrings[index]){ (info) in
                print(info)
            }
            group.leave()
        }
        group.wait()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    

    // MARK: - Making API call
    private func makeApiCall(productName: String, completion: @escaping (String) -> ()){
        let startingText = "search="
        
        var productNameForURL = startingText + productName
        productNameForURL = productNameForURL.trimmingCharacters(in: .whitespacesAndNewlines)
        productNameForURL = Utilities.replaceSpecialChars(productNameForURL, "")
        productNameForURL = productNameForURL.replacingOccurrences(of: " ", with: "&search=", options: .literal, range: nil)
        
        guard let URL = URL(string: "https://api.bestbuy.com/v1/products((\(productNameForURL)&active=true))?format=json&show=sku,name,salePrice,bestSellingRank,image,shortDescription&pageSize=100&pageSize=3&page=1&apiKey=\(self.APIKEY)")
        else {
            completion("Error: URL")
            return
        }
        /*DispatchQueue.main.async {
            //showing loading spinner
            self.showSpinner(onView: self.view)
        }*/
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
            (response) in
            if (response.result.isSuccess) {
                do {
                    let json = try JSON(data:response.data!)
                    //print(json)
                    if(json["error"].isEmpty){
                        if(json["products"].count != 0){
                            for i in 0...json["products"].count - 1{
                                let item = Product(productName: json["products"][i]["name"].stringValue,
                                                   productPrice: json["products"][i]["salePrice"].stringValue,
                                                   productDescription: json["products"][i]["shortDescription"].stringValue,
                                                   SKU: json["products"][i]["sku"].stringValue,
                                                   productThumbnailURL: json["products"][i]["image"].stringValue)
                                self.products.append(item)
                            }
                            
                            DispatchQueue.main.async {
                                //reloading the table view data
                                self.tableView.reloadData()
                                
                                // remove spinner
                                //self.removeSpinner()
                            }
                            
                            completion("Success")
                        }
                    }
                    else{
                        //self.removeSpinner()
                        //self.performSegue(withIdentifier: "segueNoProduct", sender: nil)//completion("Can't find the product.")
                    }
                }
                catch {
                    completion("Error while parsing JSON response")
                }
            }
            else{
                // remove spinner
                //self.removeSpinner()
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
            image = UIImage(named: "Logo")!;
        }
        
        cell.productImage.image = image
        cell.productName?.text = self.products[indexPath.row].productName
        cell.productPrice?.text = "$" + self.products[indexPath.row].productPrice
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        indexPathRow = indexPath.row
        self.performSegue(withIdentifier: "segueProductDetail", sender: AnyObject?.self)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueProductDetail" {
            if let productDescriptionDetailController = segue.destination as? ProductDescriptionDetailControllerViewController {
                productDescriptionDetailController.SKU = products[indexPathRow].SKU
            }
        }
    }
    

}
