//
//  DataAnalyticsTableViewCell.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-10-29.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Charts

class DataAnalyticsTableViewCell: UITableViewCell {

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var chartHeading: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
