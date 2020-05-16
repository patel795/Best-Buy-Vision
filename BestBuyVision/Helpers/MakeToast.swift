//
//  MakeToast.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-05-16.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation
import UIKit

class MakeToast{
    
    static func showToast(controller: UIViewController, message : String, seconds: Double) {
        //making a timed  alert
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        //presenting the alert as a toast.
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
}
