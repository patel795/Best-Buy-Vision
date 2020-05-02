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
        
        setUpNavigationBar()
        
        db = Firestore.firestore()
        
        // OPTIONAL:  Required when dealing with dates that are stored in Firestore
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    private func setUpNavigationBar() {
        let image = UIImage(named: "Logo2")
        let newImage = image?.imageWithColor(.white)
        let titleViewImage = UIImageView(image: newImage?.imageWithInsets(insets: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)))
        //titleViewImage.frame = CGRect(x: -0, y: 0, width: 34, height: 34)
        titleViewImage.contentMode = .scaleAspectFit
        
        navigationItem.titleView = titleViewImage
        navigationController?.navigationBar.barTintColor = Colors.bestBuyBlue
        navigationController?.navigationBar.tintColor = Colors.white
    }
    
    func  makeAlert(title:String, message:String) {
        
        //creating the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        //showing the alert on screen.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signBtnClick(_ sender: Any) {
        let user = User(email: usernameTextBox.text!, password: passwordTextBox.text!)
        
        // MARK: FB:  Try to sign the user in using Firebase Authentication
        // This is all boilerplate code copied and pasted from Firebase documentation
        Auth.auth().signIn(withEmail: user.email, password: user.password) {
            
            (user, error) in
        
            if (user != nil) {
                // 1. Found a user!
                if(user!.user.isEmailVerified) {
                    self.performSegue(withIdentifier: "segueTab", sender: nil)
                }
                else {
                    self.makeAlert(title: "Error", message: "This account is not verified yet!")
                }
            }
            else {
                // 1. A problem occured when looking up  the user
                // - doesn't meet password requirements
                print("ERROR!")
                print(error?.localizedDescription as Any)
                
                // 2. Show the error in user interface
                let errorMsg = error?.localizedDescription
                self.makeAlert(title: "Error", message: errorMsg!)
            }
        }
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        performSegue(withIdentifier: "segueSignUp", sender: nil)
    }
    
    @IBAction func unwindToThisView(sender: UIStoryboardSegue) {
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }


}

