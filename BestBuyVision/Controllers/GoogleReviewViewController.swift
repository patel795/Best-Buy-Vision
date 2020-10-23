//
//  GoogleReviewViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-05-05.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import WebKit
import Cosmos

class GoogleReviewViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var productName = ""
    let webView = WKWebView()
    var counter = 0
    var count = 0;
    var image = UIImage()
    
    var vendorCompare:String = ""
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productDataName: UILabel!
    @IBOutlet weak var productDetail: UILabel!
    @IBOutlet weak var productReview: UILabel!
    @IBOutlet weak var productComparePrices: UILabel!
    
    
    
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
                    let productData = try GoogleReviewResponse(value)
                    self.googleResponseData(productData: productData)
                } catch {}
            })
            print("loaded more")
        }
        count += 1;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButtonImage = UIImage(systemName: "arrow.left")
        let bestbuyBtn = UIButton(type: .system)
        bestbuyBtn.setImage(backButtonImage, for: .normal)
        bestbuyBtn.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        bestbuyBtn.imageView?.contentMode = .scaleAspectFit
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: bestbuyBtn)
        
        bestbuyBtn.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        
        productName = Utilities.replaceSpecialChars(productName, "")
        productName = productName.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let productURL = URL(string:"https://www.google.com/search?q=\(productName)&tbm=shop")
        
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
    }
    
    @objc private func backButton() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonTrigger(_ sender: UIButton?) {
        switch counter {
        case 0:
            webView.evaluateJavaScript("document.getElementsByClassName('p9MVp')[0].getElementsByTagName('a')[0].click();", completionHandler: nil)
        case 1:
            webView.evaluateJavaScript("document.getElementsByTagName('html')[0].innerHTML", completionHandler: { (value, error) in
                print("Value: \(String(describing: value))")
                //print("Error: \(String(describing: error))")
                do {
                    let productData = try GoogleReviewResponse(value)
                    self.googleResponseData(productData: productData)
                } catch {}
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
        self.vendorCompare = productData.googleResponses[0].vendorCompare
        print(vendorCompare)
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
