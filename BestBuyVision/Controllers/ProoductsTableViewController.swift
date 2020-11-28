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
import Firebase

class ProoductsTableViewController: UITableViewController {

    let APIKEY = "TWVhgdNpaxCG1GSk4IReKegI"
    var productNameStrings: Array<String> = Array()
    var products =  [Product]()
    var indexPathRow = Int()
    var productSKU = Int()
    var itemBrand = ""
    var productCategory = ""
    
    private var apiHandler = ApiHandlers()
    
    @IBOutlet weak var productNames: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let backButtonImage = UIImage(systemName: "arrow.left")
        let bestbuyBtn = UIButton(type: .system)
        bestbuyBtn.setImage(backButtonImage, for: .normal)
        bestbuyBtn.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        bestbuyBtn.imageView?.contentMode = .scaleAspectFit
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: bestbuyBtn)
        
        bestbuyBtn.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        */
 
        tableView.rowHeight = 115
        
        let parentVC = self.navigationController?.viewControllers[self.navigationController!.viewControllers.count-2]
        
        if (parentVC is ScanImageViewController || parentVC is LogoViewController) {
            let group = DispatchGroup()
            var apiProductString = ""
            for index in 0...(productNameStrings.count - 1) {
                
                if(apiProductString == ""){
                    apiProductString = "\(productNameStrings[index])"
                }
                else{
                    apiProductString = "\(apiProductString),\(productNameStrings[index])"
                }
                
            }
            group.enter()
            apiHandler.makeBatchApiCall(skus: apiProductString){ (info) in
                self.products = info
                self.tableView.reloadData()
                group.leave()
            }
            
            group.notify(queue: .main) {
                self.logEvents(analytic_product_array: self.products)
            }
        }
        else if parentVC is OcrViewController {
            let group = DispatchGroup()
            
            group.enter()
            apiHandler.makeApiCall(productName: "", sku: productSKU){ (info) in
                self.products = info
                self.tableView.reloadData()
                group.leave()
            }
            group.notify(queue: .main) {
                if(self.products.count == 0){
                    print("No product found")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "segueNoProduct", sender: nil)
                    }
                }
                print("done: OCR")
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func logEvents(analytic_product_array: [Product]){
        var analytic_products = [[String: Any]]()
        for item in analytic_product_array{

            let product: [String: Any] = [
                AnalyticsParameterItemID: item.SKU,
                //AnalyticsParameterItemName: productName,
                //AnalyticsParameterItemCategory: "socks",
                AnalyticsParameterItemBrand: itemBrand,
                AnalyticsParameterPrice: Double(item.productPrice),
            ]
            analytic_products.append(product)
        }
        
        var itemList: [String: Any] = [
          AnalyticsParameterItemListID: "L001",
          AnalyticsParameterItemListName: "Related products",
        ]
        itemList[AnalyticsParameterItems] = analytic_products
        Analytics.logEvent(AnalyticsEventViewItemList, parameters: itemList)
    }
    
    @objc private func backButton() {
        _ = navigationController?.popViewController(animated: true)
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
        //self.performSegue(withIdentifier: "segueProductDetail", sender: AnyObject?.self)
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
            if let productDescriptionDetailController = segue.destination as? ProductDescriptionTableViewController {
                productDescriptionDetailController.SKU = products[indexPathRow].SKU
                productDescriptionDetailController.itemBrand = itemBrand
                productDescriptionDetailController.productCategory = self.productCategory
            }
        }
    }
    

}
