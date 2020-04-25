//
//  ProductTableViewCell.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-04-24.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {


    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
