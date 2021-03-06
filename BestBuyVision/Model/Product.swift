//
//  Product.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-04-24.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation

class Product {
    var productName: String
    var productPrice: String
    var productDescription: String
    var SKU: String
    var productThumbnailURL: String
    var manufacturer: String
    var customerReviewAverage: Double
    
    init(productName: String, productPrice: String, productDescription: String, SKU: String, productThumbnailURL : String, manufacturer: String, customerReviewAverage: Double) {
        self.productName = productName
        self.productPrice = productPrice
        self.productDescription = productDescription
        self.SKU = SKU
        self.productThumbnailURL = productThumbnailURL
        self.manufacturer = manufacturer
        self.customerReviewAverage = customerReviewAverage
    }
}

