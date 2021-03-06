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
    var recommendedProducts = [ProductRecommended]()
    func makeApiCall(productName:String, sku: Int, completion: @escaping ([Product]) -> ()){
        
        var url = URL(string: "")
        
        if(productName != ""){
            let startingText = "search="
            
            let productNameForURL = startingText + productName
            
            url = URL(string: "https://api.bestbuy.com/v1/products((\(productNameForURL)&active=true))?format=json&show=sku,name,salePrice,manufacturer,bestSellingRank,image,shortDescription,customerReviewAverage&page=1&apiKey=\(self.APIKEY)")
        }
        else {
            url = URL(string: "https://api.bestbuy.com/v1/products((sku=\(sku)&active=true))?format=json&show=sku,name,salePrice,bestSellingRank,manufacturer,image,shortDescription,customerReviewAverage&page=1&apiKey=\(self.APIKEY)")
        }
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(url!, method: .get, parameters: nil).responseJSON {
            (response) in
            if (response.result.isSuccess) {
                do {
                    let json = try JSON(data:response.data!)
                    print(json)
                    //print(json)
                    if(json["error"].isEmpty){
                        if(json["products"].count != 0){
                            for i in 0...json["products"].count - 1{
                                let item = Product(productName: json["products"][i]["name"].stringValue,
                                                   productPrice: json["products"][i]["salePrice"].stringValue,
                                                   productDescription: json["products"][i]["shortDescription"].stringValue,
                                                   SKU: json["products"][i]["sku"].stringValue,
                                                   productThumbnailURL: json["products"][i]["image"].stringValue,
                                                   manufacturer: json["products"][i]["manufacturer"].stringValue,
                                                   customerReviewAverage: json["products"][i]["customerReviewAverage"].doubleValue)
                                self.products.append(item)
                            }
                            completion(self.products)
                        }
                        else{
                            completion([])
                        }
                    }
                    else{
                        completion([])
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
    
    func makeBatchApiCall(skus: String, completion: @escaping ([Product]) -> ()){
        
        let urlString = "https://api.bestbuy.com/v1/products(sku%20in%20(\(skus)))?format=json&show=sku,name,salePrice,bestSellingRank,manufacturer,image,shortDescription,customerReviewAverage&pageSize=100&apiKey=\(self.APIKEY)"
        
        let url = URL(string: urlString)
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(url!, method: .get, parameters: nil).responseJSON {
            (response) in
            if (response.result.isSuccess) {
                do {
                    let json = try JSON(data:response.data!)
                    print(json)
                    //print(json)
                    if(json["error"].isEmpty){
                        if(json["products"].count != 0){
                            for i in 0...json["products"].count - 1{
                                let item = Product(productName: json["products"][i]["name"].stringValue,
                                                   productPrice: json["products"][i]["salePrice"].stringValue,
                                                   productDescription: json["products"][i]["shortDescription"].stringValue,
                                                   SKU: json["products"][i]["sku"].stringValue,
                                                   productThumbnailURL: json["products"][i]["image"].stringValue,
                                                   manufacturer: json["products"][i]["manufacturer"].stringValue,
                                                   customerReviewAverage: json["products"][i]["customerReviewAverage"].doubleValue)
                                self.products.append(item)
                            }
                            completion(self.products)
                        }
                        else{
                            completion([])
                        }
                    }
                    else{
                        completion([])
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
    
    func makeMostViewedProductApiCall(productName:String, sku: Int, completion: @escaping ([ProductRecommended]) -> ()){
        var url = URL(string: "")
        
        if(productName != ""){
            let startingText = "search="
            
            let productNameForURL = startingText + productName
            
            url = URL(string: "https://api.bestbuy.com/beta/products/\(productNameForURL)/alsoViewed?apiKey=\(self.APIKEY)")
            
        }
        else {
            url = URL(string: "https://api.bestbuy.com/beta/products/\(sku)/alsoViewed?apiKey=\(self.APIKEY)")

        }
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(url!, method: .get, parameters: nil).responseJSON {
            (response) in
            if (response.result.isSuccess) {
                do {
                    let json = try JSON(data:response.data!)
                    //print(json["results"])
                    //print(json)
                    if(json["error"].isEmpty){
                        if(json["results"].count != 0){
                            print(json["result"][0]["names"]["title"].stringValue)
                            print(json["result"][1]["names"]["title"].stringValue)
                            for i in 0...1{
                                let item = ProductRecommended(productName: json["results"][i]["names"]["title"].stringValue, productPrice: json["results"][i]["prices"]["current"].stringValue, productThumbnailURL: json["results"][i]["images"]["standard"].stringValue, averageScore: json["results"][i]["customerReviews"]["averageScore"].stringValue, SKU: json["results"][i]["sku"].stringValue)
                                self.recommendedProducts.append(item)
                            }
                            completion(self.recommendedProducts)
                        }
                    }
                    else{
                        completion([])
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
    
    func getProductDetails(sku : String, completion: @escaping ([ProductSpecification]) -> ()){
        var details = [ProductSpecification]()
        let url = URL(string:"https://api.bestbuy.com/v1/products(sku=\(sku))?apiKey=\(self.APIKEY)&sort=sku.asc&show=details.value&format=json")
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(url!, method: .get, parameters: nil).responseJSON {
            (response) in
            if (response.result.isSuccess) {
                do {
                    let json = try JSON(data:response.data!)
                    if(json["error"].isEmpty){
                        if(json["products"].count != 0){
                            for i in 0...json["products"].count - 1{
                                for x in 0...json["products"][i]["details"].count{
                                    let productItem = ProductSpecification(name: json["products"][i]["details"][x]["name"].stringValue, value: json["products"][i]["details"][x]["value"].stringValue)
                                        
                                    details.append(productItem)
                                }
                            }
                            completion(details)
                        }
                        else{
                            completion([])
                        }
                    }
                    else{
                        completion([])
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
    
    func trendingProducts(completion: @escaping ([ProductRecommended]) -> ()){
        let url = URL(string: "https://api.bestbuy.com/beta/products/trendingViewed?apiKey=\(self.APIKEY)")
        
        Alamofire.request(url!, method: .get, parameters: nil).responseJSON {
            (response) in
            if (response.result.isSuccess) {
                do {
                    let json = try JSON(data:response.data!)
                    //print(json["results"])
                    //print(json)
                    if(json["error"].isEmpty){
                        if(json["results"].count != 0){
                            print(json["result"][0]["names"]["title"].stringValue)
                            print(json["result"][1]["names"]["title"].stringValue)
                            for i in 0...5{
                                let item = ProductRecommended(productName: json["results"][i]["names"]["title"].stringValue, productPrice: json["results"][i]["prices"]["current"].stringValue, productThumbnailURL: json["results"][i]["images"]["standard"].stringValue, averageScore: json["results"][i]["customerReviews"]["averageScore"].stringValue, SKU: json["results"][i]["sku"].stringValue)
                                self.recommendedProducts.append(item)
                            }
                            completion(self.recommendedProducts)
                        }
                    }
                    else{
                        completion([])
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
