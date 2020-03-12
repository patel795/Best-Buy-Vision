//
//  UIShadows.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-02-16.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func setShadow(opacity: Float, radius: CGFloat ) {
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
}
