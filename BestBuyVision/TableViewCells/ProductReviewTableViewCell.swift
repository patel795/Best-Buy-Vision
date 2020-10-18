//
//  ProductReviewTableViewCell.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-10-18.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class ProductReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var productReviewHeading: UILabel!
    @IBOutlet weak var productReviewNumber: UILabel!
    @IBOutlet weak var productReviewStarView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
