//
//  ProductDescriptionDetailControllerViewController.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-04-30.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProductDescriptionDetailControllerViewController: UIViewController {

    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var pageView: UIPageControl!
    let APIKEY = "TWVhgdNpaxCG1GSk4IReKegI"
    var SKU = ""
    var indexPathRow = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SKU" , SKU)
        makeApiCall(){ (info) in
            print(info)
        }
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Making API call
    private func makeApiCall(completion: @escaping (String) -> ()){
        
        guard let URL = URL(string: "https://api.bestbuy.com/v1/products(sku=\(self.SKU))?apiKey=\(self.APIKEY)&format=json")
            
        else {
            completion("Error: URL")
            return
        }
        DispatchQueue.main.async {
            //showing loading spinner
            self.showSpinner(onView: self.view)
        }
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
            (response) in
            if (response.result.isSuccess) {
                do {
                    let json = try JSON(data:response.data!)
                    print("Hello", json)
                    if(json["error"].isEmpty){
                        for i in 0...json["products"].count{
                            let item = Product(productName: json["products"][i]["name"].stringValue,
                                               productPrice: json["products"][i]["salePrice"].stringValue,
                                               productDescription: json["products"][i]["shortDescription"].stringValue,
                                               SKU: json["products"][i]["sku"].stringValue,
                                               productThumbnailURL: json["products"][i]["image"].stringValue)
                            //self.products.append(item)
                        }
                        
                        DispatchQueue.main.async {
                            //reloading the table view data
                            //self.tableView.reloadData()
                            
                            // remove spinner
                            self.removeSpinner()
                        }
                        
                        completion("Success")
                    }
                    else{
                        self.removeSpinner()
                        self.performSegue(withIdentifier: "segueNoProduct", sender: nil)
                        completion("Can't find the product.")
                    }
                }
                catch {
                    completion("Error while parsing JSON response")
                }
            }
            else{
                // remove spinner
                self.removeSpinner()
                self.performSegue(withIdentifier: "segueNoProduct", sender: nil)
                completion("Request Failed")
            }
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
