//
//  ViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-02-16.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var passwordTextBox: UITextField!
    @IBOutlet weak var usernameTextBox: UITextField!
    @IBOutlet weak var companyLogoImage: UIImageView!
    
    var db:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signinBtn.layer.cornerRadius = signinBtn.frame.size.height/2
        signinBtn.setShadow(opacity: 0.65, radius: 5.0)
        usernameTextBox.setShadow(opacity: 0.25, radius: 5.0)
        passwordTextBox.setShadow(opacity: 0.25, radius: 5.0)
        
        //setting the gradient background
        view.setGradientBackground(colorOne: Colors.white, colorTwo: Colors.blue)
        
        db = Firestore.firestore()
        
        // OPTIONAL:  Required when dealing with dates that are stored in Firestore
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
    }
    
    func  makeAlert(title:String, message:String) {
        
        //creating the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        //showing the alert on screen.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signBtnClick(_ sender: Any) {
        let username = usernameTextBox.text!
        let password = usernameTextBox.text!
        
        // MARK: FB:  Try to sign the user in using Firebase Authentication
        // This is all boilerplate code copied and pasted from Firebase documentation
        Auth.auth().signIn(withEmail: username, password: password) {
            
            (user, error) in
            
            if (user != nil) {
                // 1. Found a user!
                print("User signed in! ")
                print("User id: \(user?.user.uid ?? "Username default")")
                print("Email: \(user?.user.email ?? "email default")")
                
                self.performSegue(withIdentifier: "segueTab", sender: nil)
            }
            else {
                // 1. A problem occured when looking up  the user
                // - doesn't meet password requirements
                // - user already exists
                print("ERROR!")
                print(error?.localizedDescription as Any)
                
                // 2. Show the error in user interface
                let errorMsg = error?.localizedDescription
                self.makeAlert(title: "Error", message: errorMsg!)
            }
        
        }
    }
    
    @IBAction func signUpBtnClick(_ sender: Any) {
        performSegue(withIdentifier: "segueSignUp", sender: nil)
    }
    
    @IBAction func unwindToThisView(sender: UIStoryboardSegue) {
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }


}

