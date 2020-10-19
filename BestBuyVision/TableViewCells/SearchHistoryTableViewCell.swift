//
//  SearchHistoryTableViewCell.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-10-18.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class SearchHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var searchHistoryProductPrice: UILabel!
    @IBOutlet weak var searchHistoryProductName: UILabel!
    @IBOutlet weak var searchHistoryImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
