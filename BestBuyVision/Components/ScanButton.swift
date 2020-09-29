//
//  ScanButton.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-09-29.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation
import UIKit
 
class ScanButton: UIButton {
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        setTitle("Scan document", for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        titleLabel?.textColor = .white
        layer.cornerRadius = 7.0
        backgroundColor = Colors.bestBuyBlue
    }
}
