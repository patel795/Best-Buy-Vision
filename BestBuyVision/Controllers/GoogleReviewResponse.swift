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
    var productReview = ""
    var imageLinks = ""
    var productNames = ""
    var productDetail = ""
    
    let googleResponses: [GoogleModel]
    init(_ innerHTML: Any?) throws {
        guard let htmlString = innerHTML as? String else
            { throw HTMLError.badInnerHTML }
        //[0].getElementsByTagName('img')[0].getAttribute('src')
        let doc = try SwiftSoup.parse(htmlString)
        
        if (try doc.getElementsByClass("oR27Gd").count > 0){
            imageLinks = try doc.getElementsByClass("oR27Gd")[0].getElementsByTag("img")[0].attr("src")
        }
        else {
            imageLinks = "No Image Found"
        }
        
        if (try doc.getElementsByClass("fbrNcd").count > 0){
            productNames = try doc.getElementsByClass("fbrNcd")[0].getElementsByTag("a")[0].text()
        }
        else{
            productNames = "No Product Name Found"
        }
        
        if (try doc.getElementsByClass("kBBuHb").count > 0){
            productDetail = try doc.getElementsByClass("kBBuHb")[0].child(0).text()
            
            for n in 1...(try doc.getElementsByClass("kBBuHb")[0].children().count - 1) {
                productDetail.append("\n\(try doc.getElementsByClass("kBBuHb")[0].child(n).text())")
            }
        }
        else {
            productDetail = "No Product Details Found"
        }

        if (try doc.getElementsByClass("VOVcm").count > 1){
            print(try doc.getElementsByClass("VOVcm")[0].text())
            productDetail.append("\n\(try doc.getElementsByClass("VOVcm")[1].text())")
        }
        
        if(try doc.getElementsByClass("bJkpaf").count > 0){
            productReview = try doc.getElementsByClass("bJkpaf")[0].text()
        }
        else{
            productReview = "NULL"
        }
        var vendorCompare = ""
        if(try doc.getElementsByClass("t9KcM").count > 0){
            vendorCompare = try doc.getElementsByClass("t9KcM")[0].child(1).text()
            vendorCompare.append(" - \(try doc.getElementsByClass("t9KcM")[0].child(0).child(0).text())")
            //print(try doc.getElementsByClass("t9KcM").count)
            if(try doc.getElementsByClass("t9KcM").count > 1){
                for n in 1...(try doc.getElementsByClass("t9KcM").count - 1) {
                    //print(try doc.getElementsByClass("t9KcM")[n])
                    if (try doc.getElementsByClass("t9KcM")[n] != nil){
                        vendorCompare.append("\n\(try doc.getElementsByClass("t9KcM")[n].child(1).text()) - \(try doc.getElementsByClass("t9KcM")[n].child(0).child(0).text())")
                    }
                }
            }
        }
        else{
            vendorCompare = "No Vendors Found"
        }
        var googleResponses = [GoogleModel]()
        
        let productResponse = GoogleModel(imageLink: imageLinks, productName: productNames, productDetail: productDetail, productReview: productReview, vendorCompare: vendorCompare)
        googleResponses.append(productResponse)
        
        self.googleResponses = googleResponses
    }
}
