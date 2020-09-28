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
        
        print(imageLinks)
        var googleResponses = [GoogleModel]()
        
        let productResponse = GoogleModel(imageLink: imageLinks)
        googleResponses.append(productResponse)
        
        self.googleResponses = googleResponses
    }
}
