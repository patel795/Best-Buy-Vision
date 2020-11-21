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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
