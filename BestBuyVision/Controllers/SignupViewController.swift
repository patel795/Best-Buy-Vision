//
//  SignupViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-02-16.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Firebase
import WebKit

class SignupViewController: UIViewController {

    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var confirmTextBox: UITextField!
    @IBOutlet weak var passwordTextBox: UITextField!
    @IBOutlet weak var emailTextBox: UITextField!
    @IBOutlet weak var companyLogoImage: UIImageView!
    
    // MARK: Initialize firestore variable
    // ------------------------------------
    var db:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()

        db = Firestore.firestore()
        
        // OPTIONAL:  Required when dealing with dates that are stored in Firestore
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        // Do any additional setup after loading the view.
    }
    
    private func setUpNavigationBar() {
        let image = UIImage(named: "Logo2")
        let newImage = image?.imageWithColor(.white)
        let titleViewImage = UIImageView(image: newImage?.imageWithInsets(insets: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 500)))
       
        titleViewImage.contentMode = .scaleAspectFit
        
        navigationItem.titleView = titleViewImage
        
    }
    
    func  makeAlert(title:String, message:String) {
        
        //creating the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        //showing the alert on screen.
        self.present(alert, animated: true, completion: nil)
    }
    
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        
        //making a timed  alert
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        //presenting the alert as a toast.
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
            if(seconds == 1.0){
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBAction func signUpBtnPressed(_ sender: Any) {
        let confirmPassword = confirmTextBox.text!
        let user = User(email: self.emailTextBox.text!, password: self.passwordTextBox.text!)
        
        if(user.password == confirmPassword){
            // MARK: FB:  Try to create a user using Firebase Authentication
            // This is all boilerplate code copied and pasted from Firebase documentation
            Auth.auth().createUser(withEmail: user.email, password: user.password) {
                
                (user, error) in
                
                if (user != nil) {
                    user?.user.sendEmailVerification { (error) in
                        print(error ?? "error unknown")
                    }
                    self.showToast(controller: self, message : "Account has been registered, to login please verify your email.", seconds: 1.0)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    // 1. Error when creating a user
                    print("ERROR!")
                    print(error?.localizedDescription as Any)
                    
                    // 2. Show the error in the UI
                    let errorMsg = error?.localizedDescription
                    self.makeAlert(title: "Error", message: errorMsg!)
                }
            }
        }
        else{
            makeAlert(title: "Wrong Password", message: "Please enter the correct password in confirmation field.")
        }
        
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
