//
//  ViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-02-16.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var passwordTextBox: UITextField!
    @IBOutlet weak var usernameTextBox: UITextField!
    @IBOutlet weak var companyLogoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginBtn.layer.cornerRadius = loginBtn.frame.size.height/2
        loginBtn.setShadow(opacity: 0.65, radius: 5.0)
        usernameTextBox.setShadow(opacity: 0.25, radius: 5.0)
        passwordTextBox.setShadow(opacity: 0.25, radius: 5.0)
        
        //setting the gradient background
        view.setGradientBackground(colorOne: Colors.loginColorOne, colorTwo: Colors.loginColorTwo)
        
    }


}

