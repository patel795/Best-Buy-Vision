//
//  SettingsViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-11-20.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    let db = Firestore.firestore()

    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Utilities.styleTextField(emailTextField)
        
        emailTextField.text = Auth.auth().currentUser!.email
    }
    
    @IBAction func resetPasswordBtnClick(_ sender: Any) {
        let email = Auth.auth().currentUser!.email
        if (email == "") {
            makeAlert.showAlert(controller: self,title: "No Email Adddress", message: "Error..Please enter your email address")
        }
        else{
            Auth.auth().sendPasswordReset(withEmail: email!) {
                error in
                
                if (error == nil) {
                    MakeToast.showToast(controller: self, message : "Reset Password Link has been sent to your email address", seconds: 1.0)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    // 1. Error when creating a user
                    print("ERROR!")
                    print(error?.localizedDescription as Any)
                    
                    // 2. Show the error in the UI
                    let errorMsg = error?.localizedDescription
                    makeAlert.showAlert(controller: self, title: "Error", message: errorMsg!)
                }
                //print(error ?? "error unknown")
            }
        }
    }
    
    private func isUserManager(completion: @escaping (Bool) -> ()){
        var firebaseData = [String: Any]()
        
        let group = DispatchGroup()
        group.enter()
        self.db.collection("ManagerAccess").getDocuments() {
            (querySnapshot, err) in
            
            // MARK: FB - Boilerplate code to get data from Firestore
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if(document.documentID == "isAllowed"){
                        firebaseData = data
                    }
                }
            }
            group.leave()
        }
        
        
        group.notify(queue: .main) {
            if(!firebaseData.isEmpty){
                let accessLevelArray:[String] = firebaseData["manager_list"] as! [String]
                if(!accessLevelArray.isEmpty){
                    let userId = Auth.auth().currentUser!.uid
                    let tyrpe = type(of: userId)
                    let result = accessLevelArray.contains(userId)
                    completion(result)
                }
                else{
                    completion(false)
                }
            }
        }
    }
    
    @IBAction func dataAnalyticsBtnClick(_ sender: Any) {
        isUserManager(){ (info) in
            print(info)
            if(info == true){
                self.performSegue(withIdentifier: "segueDataAnalytics", sender: nil)
            }
            else{
                self.performSegue(withIdentifier: "segueCustomerDA", sender: nil)
            }
        }
    }
    
    
    @IBAction func logOut(_ sender: Any) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                do {
                    try Auth.auth().signOut()
                    //navigationController?.popToRootViewController(animated: true)
                    //let mainViewController = ViewController()
                    //let mainmenuViewNavigationController = UINavigationController(rootViewController: mainViewController)
                    //self.present(mainmenuViewNavigationController, animated: true, completion: nil)
                    self.performSegue(withIdentifier: "unwindToViewController", sender: self)
                    } catch let err {
                        print(err)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
