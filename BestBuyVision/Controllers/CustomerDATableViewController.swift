//
//  CustomerDATableViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-11-20.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Cosmos

class CustomerDATableViewController: UITableViewController {
    var ratingsArray = [Any]()
    var companyNames = [String]()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        getDataFromFirebase(){(info) in
            print(info)
            self.ratingsArray = Array(info.values)
            self.companyNames = Array(info.keys)
            print("======== \n \(self.ratingsArray[0])")
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ratingsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath) as! CompanyRatingsTableViewCell

        let starView: CosmosView = {
            let view  = CosmosView()
            view.settings.updateOnTouch = false
            view.rating = ratingsArray[indexPath.row] as! Double
            view.settings.fillMode = .precise
            return view
        }()
        
        // Configure the cell...
        cell.companyName.text = companyNames[indexPath.row]
        cell.companyRating.text = String(format: "%.2f", ratingsArray[indexPath.row] as! Double)
        cell.cosmosView.addSubview(starView)
        return cell
    }
    
    private func getDataFromFirebase(completion: @escaping ([String: Any]) -> ()){
        var firebaseData = [String: Any]()
        
        let group = DispatchGroup()
        group.enter()
        self.db.collection("CustomerDataAnalytics").getDocuments() {
            (querySnapshot, err) in
            
            // MARK: FB - Boilerplate code to get data from Firestore
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if(document.documentID == "\(Auth.auth().currentUser!.uid)"){
                        firebaseData = data
                    }
                }
            }
            group.leave()
        }
        
        
        group.notify(queue: .main) {
            if(!firebaseData.isEmpty){
                completion(firebaseData)
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
