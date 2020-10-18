//
//  GoogleReviewResponse.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-09-24.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation
import SwiftSoup

enum HTMLError: Error {
    case badInnerHTML
}

struct GoogleReviewResponse {
    
    let googleResponses: [GoogleModel]
    init(_ innerHTML: Any?) throws {
        guard let htmlString = innerHTML as? String else
            { throw HTMLError.badInnerHTML }
        //[0].getElementsByTagName('img')[0].getAttribute('src')
        let doc = try SwiftSoup.parse(htmlString)
        
        let imageLinks = try doc.getElementsByClass("oR27Gd")[0].getElementsByTag("img")[0].attr("src")
        let productNames = try doc.getElementsByClass("fbrNcd")[0].getElementsByTag("a")[0].text()
        
        var productDetail = try doc.getElementsByClass("kBBuHb")[0].child(0).text()
        for n in 1...4 {
            productDetail.append("\n\(try doc.getElementsByClass("kBBuHb")[0].child(n).text())")
        }
        productDetail.append("\n\(try doc.getElementsByClass("VOVcm")[1].text())")
        
        let productReview = try doc.getElementsByClass("bJkpaf")[0].text()
        
        var vendorCompare = try doc.getElementsByClass("t9KcM")[0].child(1).text()
        vendorCompare.append(" - \(try doc.getElementsByClass("t9KcM")[0].child(0).child(0).text())")
        for n in 1...4 {
            print(try doc.getElementsByClass("t9KcM")[n])
            if (try doc.getElementsByClass("t9KcM")[n] != nil){
                vendorCompare.append("\n\(try doc.getElementsByClass("t9KcM")[n].child(1).text()) - \(try doc.getElementsByClass("t9KcM")[n].child(0).child(0).text())")
            }
        }

        var googleResponses = [GoogleModel]()
        
        let productResponse = GoogleModel(imageLink: imageLinks, productName: productNames, productDetail: productDetail, productReview: productReview, vendorCompare: vendorCompare)
        googleResponses.append(productResponse)
        
        self.googleResponses = googleResponses
    }
}
