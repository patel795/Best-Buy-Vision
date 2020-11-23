//
//  GoogleReviewTableViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-10-15.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit
import Cosmos

class GoogleReviewTableViewController: UITableViewController, WKNavigationDelegate, WKUIDelegate {

    var productName = ""
    let webView = WKWebView()
    var counter = 0
    var count = 0;
    var image = UIImage()
    var productData: GoogleReviewResponse?
    var vendorCompare:String = ""
    
    func webView(_ webView: WKWebView,
      didFinish navigation: WKNavigation!) {
        print("loaded")
        if (count == 0){
            webView.evaluateJavaScript("document.getElementsByClassName('p9MVp')[0].getElementsByTagName('a')[0].click();", completionHandler: nil)
        }
        else if(count == 1){
            webView.evaluateJavaScript("document.getElementsByTagName('html')[0].innerHTML", completionHandler: { (value, error) in
                print("Value: \(String(describing: value))")
                //print("Error: \(String(describing: error))")
                do {
                    self.productData = try GoogleReviewResponse(value)
                    self.googleResponseData(productData: self.productData!)
                    self.tableView.reloadData()
                } catch {}
            })
            print("loaded more")
        }
        count += 1;
        self.removeSpinner()
    }
    
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
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        tabBarController?.navigationItem.title = "Google Review"
        tableView.allowsSelection = false
        
        productName = Utilities.replaceSpecialChars(productName, "")
        productName = productName.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let productURL = URL(string:"https://www.google.com/search?q=\(productName)&tbm=shop")
        
        self.showSpinner(onView: self.view)
        if(productURL != nil){
            let myRequest = URLRequest(url: productURL!)
            //webView.frame = CGRect(x:0, y:300, width: 300, height: 300)
            webView.navigationDelegate = self
            webView.load(myRequest)
            
            //view.addSubview(webView)
        }
        else{
            MakeToast.showToast(controller: self, message: "No Product Found", seconds: 2.0)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
      
    }
    
    @objc private func backButton() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func googleResponseData(productData: GoogleReviewResponse){
        let url = NSURL(string: productData.googleResponses[0].imageLink)
        
        if(url?.absoluteString != ""){
            let data = NSData(contentsOf : url as! URL)
            self.image = UIImage(data : data! as Data)!
        }
        else{
            self.image = UIImage(named: "Logo")!;
        }
        
        //self.productImage.image = self.image
        //self.productDataName.text =
        //self.productDetail.text = productData.googleResponses[0].productDetail
        //self.productReview.text = "\(productData.googleResponses[0].productReview) / 5.0"
        //self.vendorCompare = productData.googleResponses[0].vendorCompare
        print(vendorCompare)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productImageCell", for: indexPath)
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "productImageCell", for: indexPath) as! GoogleReviewImageTableViewCell
            cell.GoogleReviewImageView.image = self.image
            cell.NameLabel.text = self.productData?.googleResponses[0].productName
            
            return cell
        }
        else if(indexPath.row == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "productDetailCell", for: indexPath) as! ProductDetailTableViewCell
            cell.productDetailLabel.text = self.productData?.googleResponses[0].productDetail
            
            return cell
        }
        else if(indexPath.row == 2){
            let ratingNumber = Double(self.productData?.googleResponses[0].productReview ?? "0")
            let starView: CosmosView = {
                let view  = CosmosView()
                view.settings.updateOnTouch = false
                view.rating = ratingNumber ?? 0
                view.settings.fillMode = .precise
                return view
            }()
            let cell = tableView.dequeueReusableCell(withIdentifier: "productReviewCell", for: indexPath) as! ProductReviewTableViewCell
            cell.productReviewNumber.text = self.productData?.googleResponses[0].productReview
            cell.productReviewStarView.addSubview(starView)
            return cell
        }
        else if(indexPath.row == 3){
            let cell = tableView.dequeueReusableCell(withIdentifier: "productVendorCell", for: indexPath) as! ProductVendorCompareTableViewCell
            cell.vendorLabel.text = self.productData?.googleResponses[0].vendorCompare
            
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
