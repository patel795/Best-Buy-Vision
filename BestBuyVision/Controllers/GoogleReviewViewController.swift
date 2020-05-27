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

    @IBOutlet weak var googleReviewWebKit: WKWebView!
    var productName = ""
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        googleReviewWebKit = WKWebView(frame: .zero, configuration: webConfiguration)
        googleReviewWebKit.uiDelegate = self
        view = googleReviewWebKit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productName = Utilities.replaceSpecialChars(productName, "")
        productName = productName.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let productURL = URL(string:"https://www.google.com/search?q=\(productName)&tbm=shop")
        
        if(productURL != nil){
            let myRequest = URLRequest(url: productURL!)
            googleReviewWebKit.load(myRequest)
        }
        else{
            MakeToast.showToast(controller: self, message: "No Product Found", seconds: 2.0)
        }
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
