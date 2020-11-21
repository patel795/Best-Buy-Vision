//
//  CompanyRatingsTableViewCell.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-11-20.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class CompanyRatingsTableViewCell: UITableViewCell {

    @IBOutlet weak var cosmosView: UIView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companyRating: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
