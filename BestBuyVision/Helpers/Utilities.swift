//
//  Utilities.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-05-02.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 0/255.0, green: 62.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleTextField(_ textfield:UITextField, borderColor: UIColor) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = borderColor.cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.black
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func replaceSpecialChars(_ text: String, _ replaceString: String)  -> String{
        let specialChars = ["\"", "_", "+", "(", ")", "\u{00B9}", "\u{00B2}", "\u{00B3}",
                            "\u{2074}", "\u{2075}", "\u{2076}", "\u{2077}", "\u{2078}", "\u{2079}", "\u{2122}"]
        var resultString = text
        for char in specialChars{
            resultString = resultString.replacingOccurrences(of: "\(char)", with: replaceString, options: .literal, range: nil)
        }
        return resultString
    }
}
