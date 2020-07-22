//
//  GoogleVisionLogoDetector.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-07-09.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation
import Alamofire

class GoogleVisionLogoDetector {
    private let apiKey = "AIzaSyCzLSUUvbBGqdEpGURt3iHbG5RYEC2RUVw"
    
    private var apiURL: URL {
      return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)")!
    }

    func detect(from image: UIImage, completion: @escaping (companyName?) -> Void) -> Data{
      guard let base64Image = base64EncodeImage(image) else {
        print("Error while base64 encoding image")
        completion(nil)
        return Data.empty
      }
      return callGoogleVisionAPI(with: base64Image, completion: completion)
    }

    private func callGoogleVisionAPI(
      with base64EncodedImage: String,
      completion: @escaping (companyName?) -> Void) -> Data {
        var result:Data = Data.empty
      let parameters: Parameters = [
        "requests": [
          [
            "image": [
              "content": base64EncodedImage
            ],
            "features": [
              [
                "type": "LOGO_DETECTION"
              ]
            ]
          ]
        ]
      ]
      let headers: HTTPHeaders = [
        "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? "",
        ]
      Alamofire.request(
        apiURL,
        method: .post,
        parameters: parameters,
        encoding: JSONEncoding.default,
        headers: headers)
        .responseJSON { response in
          if response.result.isFailure {
            completion(nil)
            return
          }
          print(response.result.debugDescription)
            result = response.data!
      }
        return result
    }

    private func base64EncodeImage(_ image: UIImage) -> String? {
      return image.pngData()?.base64EncodedString(options: .endLineWithCarriageReturn)
    }
}
