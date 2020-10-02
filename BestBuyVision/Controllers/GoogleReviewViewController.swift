//
//  GoogleReviewViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-05-05.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import WebKit

class GoogleReviewViewController: UIViewController, WKUIDelegate {

    var productName = ""
    let webView = WKWebView()
    var counter = 0
    var image = UIImage()
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productDataName: UILabel!
    @IBOutlet weak var productDetail: UILabel!
    @IBOutlet weak var productReview: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productName = Utilities.replaceSpecialChars(productName, "")
        productName = productName.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let productURL = URL(string:"https://www.google.com/search?q=\(productName)&tbm=shop")
        
        print(productName)
        print(productURL)
        if(productURL != nil){
            let myRequest = URLRequest(url: productURL!)
            webView.frame = CGRect(x:0, y:900, width: 300, height: 300)
            webView.load(myRequest)
            view.addSubview(webView)
        }
        else{
            MakeToast.showToast(controller: self, message: "No Product Found", seconds: 2.0)
        }
    }
    
    @IBAction func buttonTrigger(_ sender: Any) {
        switch counter {
        case 0:
            webView.evaluateJavaScript("document.getElementsByClassName('p9MVp')[0].getElementsByTagName('a')[0].getAttribute('href')", completionHandler: {
                (value, error) in
                print("Value: \(String(describing: value))")
                print("Error: \(String(describing: error))")
            })
        case 1:
            webView.evaluateJavaScript("document.getElementsByClassName('p9MVp')[0].getElementsByTagName('a')[0].click();", completionHandler: nil)
        case 2:
            webView.evaluateJavaScript("document.getElementsByTagName('html')[0].innerHTML", completionHandler: { (value, error) in
                print("Value: \(String(describing: value))")
                //print("Error: \(String(describing: error))")
                do {
                    let productData = try GoogleReviewResponse(value)
                    self.googleResponseData(productData: productData)
                } catch {}
            })
        case 3:
            webView.evaluateJavaScript("document.getElementsByClassName('oR27Gd')[0].getElementsByTagName('img')[0].getAttribute('src')", completionHandler: {
                (value, error) in
                print("Value: \(String(describing: value))")
                print("Error: \(String(describing: error))")
            })
        default:
            print("Hello")
        }
        counter += 1
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
        
        self.productImage.image = self.image
        self.productDataName.text = productData.googleResponses[0].productName
        self.productDetail.text = productData.googleResponses[0].productDetail
        self.productReview.text = "\(productData.googleResponses[0].productReview) / 5.0"
        
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
