//
//  DataAnalyticsTableViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-10-29.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Charts
import Firebase

class DataAnalyticsTableViewController: UITableViewController {
    let db = Firestore.firestore()
    var rowCount = 0
    var documentNames:[String] = [String]()
    var pieChartViews = [PieChartView]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 409
        
        let group = DispatchGroup()
        group.enter()
        self.db.collection("LoggedEvents").getDocuments(){
            (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.rowCount = querySnapshot!.count
                for document in querySnapshot!.documents {
                    self.documentNames.append(document.documentID)
                }
            }
            group.leave()
        }
        group.notify(queue: .main){
            self.updateCharts()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func updateCharts(){
        let group = DispatchGroup()
        
        self.showSpinner(onView: self.view)
        group.enter()
        for index in 0...self.documentNames.count-1{
            let pieChartView = PieChartView()
            self.getDataFromFirebase(documentArray: documentNames[index], pieChart: pieChartView)
            self.pieChartViews.append(pieChartView)
            self.tableView.reloadData()
            if(index == self.documentNames.count - 1){
                group.leave()
            }
        }
        group.notify(queue: .main){
            
            //self!.customizeChart(dataPoints: keys, values: values.map{ Double($0) })
            self.removeSpinner()
        }
        
    }
    
    private func getDataFromFirebase(documentArray: String, pieChart: PieChartView){
        
            var firebaseData = [String: Any]()

            let group = DispatchGroup()
            group.enter()
            self.db.collection("LoggedEvents").getDocuments() {
                (querySnapshot, err) in
                
                // MARK: FB - Boilerplate code to get data from Firestore
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if(document.documentID == documentArray){
                            firebaseData = data
                        }
                    }
                }
                group.leave()
            }
            group.notify(queue: .main) {
                if(!firebaseData.isEmpty){
                    var keys: [String] = [String]()
                    var values: [Double] = [Double]()
                    
                    for item in firebaseData{
                        keys.append(item.key)
                        values.append((item.value as? Double)!)
                    }
                    print(values)
                    self.customizeChart(dataPoints: keys, values: values.map{ Double($0) }, pieChartView: pieChart)
                    self.tableView.reloadData()
                }
            }
    }
    
    func customizeChart(dataPoints: [String], values: [Double], pieChartView: PieChartView) {
        var dataEntries: [ChartDataEntry] = []
          for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
          }
          // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        // 4. Assign it to the chart’s data
        pieChartView.data = pieChartData
        
    }

    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
      var colors: [UIColor] = []
      for _ in 0..<numbersOfColor {
        let red = Double(arc4random_uniform(256))
        let green = Double(arc4random_uniform(256))
        let blue = Double(arc4random_uniform(256))
        let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
        colors.append(color)
      }
      return colors
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rowCount
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataAnalyticsCell", for: indexPath) as! DataAnalyticsTableViewCell

        // Configure the cell...
        
        cell.chartHeading.text = self.documentNames[indexPath.row]
        cell.pieChartView.data = pieChartViews[indexPath.row].data

        return cell
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
