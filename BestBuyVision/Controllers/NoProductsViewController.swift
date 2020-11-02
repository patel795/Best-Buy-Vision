//
//  NoProductsViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-11-01.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class NoProductsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        
        let backButtonImage = UIImage(systemName: "arrow.left")
        let backBtn = UIButton(type: .system)
        backBtn.setImage(backButtonImage, for: .normal)
        backBtn.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        backBtn.imageView?.contentMode = .scaleAspectFit
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationItem.hidesBackButton = false
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
