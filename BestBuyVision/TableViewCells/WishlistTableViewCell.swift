//
//  WishlistTableViewCell.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-10-18.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class WishlistTableViewCell: UITableViewCell {

    @IBOutlet weak var wishlistProductPrice: UILabel!
    @IBOutlet weak var wishlistProductName: UILabel!
    @IBOutlet weak var wishlistProductImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
