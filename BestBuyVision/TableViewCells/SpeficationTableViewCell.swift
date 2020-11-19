//
//  SpeficationTableViewCell.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-11-19.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class SpeficationTableViewCell: UITableViewCell {
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
