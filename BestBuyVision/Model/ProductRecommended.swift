//
//  ProductRecommended.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-11-01.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation

class ProductRecommended {
    var productName: String
    var productPrice: String
    var productThumbnailURL: String
    var averageScore : String
    var SKU: String
    
    init(productName: String, productPrice: String, productThumbnailURL : String, averageScore: String, SKU: String) {
        self.productName = productName
        self.productPrice = productPrice
        self.productThumbnailURL = productThumbnailURL
        self.averageScore = averageScore
        self.SKU = SKU
    }
}
