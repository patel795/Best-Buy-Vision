//
//  ViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-02-16.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var passwordTextBox: UITextField!
    @IBOutlet weak var usernameTextBox: UITextField!
    @IBOutlet weak var companyLogoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signinBtn.layer.cornerRadius = signinBtn.frame.size.height/2
        signinBtn.setShadow(opacity: 0.65, radius: 5.0)
        usernameTextBox.setShadow(opacity: 0.25, radius: 5.0)
        passwordTextBox.setShadow(opacity: 0.25, radius: 5.0)
        
        //setting the gradient background
        view.setGradientBackground(colorOne: Colors.white, colorTwo: Colors.blue)
        
    }
    
    @IBAction func signBtnClick(_ sender: Any) {
        performSegue(withIdentifier: "segueTab", sender: nil)
    }
    
    @IBAction func signUpBtnClick(_ sender: Any) {
        performSegue(withIdentifier: "segueSignUp", sender: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }


}

