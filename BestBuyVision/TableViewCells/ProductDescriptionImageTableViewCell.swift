//
//  ProductDescriptionImageTableViewCell.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-11-11.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import ImageSlideshow

class ProductDescriptionImageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var productDescriptionImageSlideShow: ImageSlideshow!
    @IBOutlet weak var productDescriptionProductName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
