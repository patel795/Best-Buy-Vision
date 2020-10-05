//
//  CardsUIView.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-07-23.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation
import UIKit

class CardsUIView{
    let viewBorder = CAShapeLayer()
    let verticalStack = UIStackView()
    let childView = UIView()
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
    var productImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: Double(UIScreen.main.bounds.width) * 0.7, height: Double(200)))
    
    func createSubView(mainView: UIView, headerLabel: String, x_coordinate: Double, y_coordinate: Double, forMainMenuLogo: Bool) -> UIView{
        
        if(forMainMenuLogo){
            childView.frame = CGRect(x: x_coordinate, y: y_coordinate, width: Double(UIScreen.main.bounds.width) * 0.4, height: Double(200))
        }
        else{
            childView.frame = CGRect(x: x_coordinate, y: y_coordinate, width: Double(UIScreen.main.bounds.width) * 0.9, height: Double(200))
        }
        
        /*
        childView.layer.borderWidth = 8
        childView.layer.borderColor = UIColor.gray.cgColor
        */
        
        viewBorder.strokeColor = UIColor.gray.cgColor
        viewBorder.lineDashPattern = [5, 3]
        viewBorder.lineWidth = 3
        viewBorder.frame = childView.bounds
        viewBorder.fillColor = nil
        
        if(forMainMenuLogo){
            viewBorder.path = UIBezierPath(roundedRect: childView.bounds, cornerRadius: childView.frame.height / 6.0).cgPath
        }
        else{
            viewBorder.path = UIBezierPath(roundedRect: childView.bounds, cornerRadius: childView.frame.height / 4.0).cgPath
        }
        childView.layer.addSublayer(viewBorder)
        
        //Stack View
        
        verticalStack.axis = NSLayoutConstraint.Axis.vertical
        verticalStack.distribution  = UIStackView.Distribution.equalSpacing
        verticalStack.alignment = UIStackView.Alignment.center
        verticalStack.spacing   = 5.0

        var image = UIImage()
        
        if(forMainMenuLogo){
            image = UIImage(named: "ImageRecognitionLogo")!
        }
        else{
            image = UIImage(systemName: "camera")!
        }
        
        let imageView = UIImageView(image: image)
        
        imageView.tintColor = UIColor.gray
        imageView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        imageView.contentMode = .scaleAspectFit
 
        
        label.widthAnchor.constraint(equalToConstant: 140).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        label.textAlignment = .center
        label.text = headerLabel
        
        verticalStack.addArrangedSubview(imageView)
        verticalStack.addArrangedSubview(label)
        
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        childView.addConstraint(NSLayoutConstraint(item: verticalStack, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: childView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
        childView.addConstraint(NSLayoutConstraint(item: verticalStack, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: childView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
        
        childView.addSubview(verticalStack)
        
        return childView
    }
    
    func changeImageView(){
        verticalStack.isHidden = true
        childView.addSubview(productImageView)
        productImageView.contentMode = .scaleAspectFill
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        childView.addConstraint(NSLayoutConstraint(item: productImageView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: childView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
        childView.addConstraint(NSLayoutConstraint(item: productImageView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: childView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
        childView.addConstraint(NSLayoutConstraint(item: productImageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: childView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0))
        childView.addConstraint(NSLayoutConstraint(item: productImageView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: childView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0))
        productImageView.layer.cornerRadius = childView.frame.height / 4.0
        productImageView.clipsToBounds = true
        productImageView.isHidden = false
    }
    
    func getChildView() -> UIView{
        return childView
    }
    
    func getProductImageView() -> UIImageView{
        return productImageView
    }
}
