//
//  ForgotPasswordViewController.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-05-17.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailAddressTextBox: UITextField!
    @IBOutlet weak var sendLinkBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        
        sendLinkBtn.layer.cornerRadius = sendLinkBtn.frame.size.height/2
        Utilities.styleTextField(emailAddressTextBox)

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
    
    @IBAction func sendLink(_ sender: Any) {
        let email = self.emailAddressTextBox.text!
        if (email == "") {
            self.makeAlert(title: "No Email Adddress", message: "Error..Please enter your email address")
        }
        else{
            Auth.auth().sendPasswordReset(withEmail: email) {
                error in
                
                if (error == nil) {
                    self.showToast(controller: self, message : "Reset Password Link has been sent to your email address", seconds: 1.0)
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
                //print(error ?? "error unknown")
            }
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
