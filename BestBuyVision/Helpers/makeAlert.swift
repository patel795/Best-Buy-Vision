//
//  makeAlert.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-06-24.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation
import UIKit

class makeAlert{
    
    static func showAlert(controller: UIViewController, title:String, message:String) {
        
        //creating the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        //showing the alert on screen.
        controller.present(alert, animated: true, completion: nil)
    }
    
}
