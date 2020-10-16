//
//  GoogleReviewImageTableViewCell.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-10-15.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class GoogleReviewImageTableViewCell: UITableViewCell {

    @IBOutlet weak var GoogleReviewImageView: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
