//
//  ApiHandlers.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-09-29.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ApiHandlers{
    let APIKEY = "TWVhgdNpaxCG1GSk4IReKegI"
    var products =  [Product]()
    func makeApiCall(sku: Int, completion: @escaping ([Product]) -> ()){
        
        guard let URL = URL(string: "https://api.bestbuy.com/v1/products((sku=\(sku)&active=true))?format=json&show=sku,name,salePrice,bestSellingRank,image,shortDescription&pageSize=100&pageSize=3&page=1&apiKey=\(self.APIKEY)")
        else {
            completion([])
            return
        }
        
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
                            completion(self.products)
                        }
                    }
                    else{
                        //self.removeSpinner()
                        //self.performSegue(withIdentifier: "segueNoProduct", sender: nil)//completion("Can't find the product.")
                    }
                }
                catch {
                    completion([])
                }
            }
            else{
                completion([])
            }
        }
    }
}
