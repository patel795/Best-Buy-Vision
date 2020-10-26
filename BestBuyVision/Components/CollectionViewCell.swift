//
//  CollectionViewCell.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-10-25.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    class var reuseIdentifier: String {
        return "CollectionViewCellReuseIdentifier"
    }
    
    class var nibName: String {
        return "CollectionViewCell"
    }
    
    func configureCell(name: String) {
        self.nameLabel.text = name
    }

}
