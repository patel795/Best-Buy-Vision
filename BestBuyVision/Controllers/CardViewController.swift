//
//  CardViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-07-23.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import SwiftUI

class CardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let cardView = CardsUIView()
        
        let x = (UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.9)/2
        let y = 100
        
        view.addSubview(cardView.createSubView(mainView: view, headerLabel: "Image of the logo", x_coordinate: Double(x), y_coordinate: Double(y), forMainMenuLogo: false))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
