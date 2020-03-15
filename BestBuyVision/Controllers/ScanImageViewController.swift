//
//  ScanImageViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-02-16.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ScanImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let APIKEY = "TWVhgdNpaxCG1GSk4IReKegI"

    @IBOutlet weak var productName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let vc = UIImagePickerController()
        //vc.sourceType = .camera
        //vc.allowsEditing = true
        //vc.delegate = self
        //present(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.hidesBackButton = true
        setUpNavigationBar()
    }
    
    private func setUpNavigationBar() {
        let image = UIImage(named: "Logo2")
        let newImage = image?.imageWithColor(.white)
        var titleViewImage = UIImageView()
        titleViewImage = UIImageView(image: newImage?.imageWithInsets(insets: UIEdgeInsets(top: 300, left: 0, bottom: 300, right: 7000)))
        titleViewImage.contentMode = .scaleAspectFit
        
        tabBarController?.navigationItem.titleView = titleViewImage
        
        let accountImage = UIImage(systemName: "person.circle")
        
        let bestbuyBtn = UIButton(type: .system)
        bestbuyBtn.setImage(accountImage, for: .normal)
        bestbuyBtn.imageView?.contentMode = .scaleAspectFit
        bestbuyBtn.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bestbuyBtn)
    }
    
    private func makeApiCall(){
        let startingText = "search="
        var productNameString = productName.text!
        productNameString = startingText + productNameString
        productNameString = productNameString.replacingOccurrences(of: " ", with: "&search=", options: .literal, range: nil)
       
        let URL = "https://api.bestbuy.com/v1/products(\(productNameString))?format=json&show=sku,name,salePrice&apiKey=\(APIKEY)"
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
            (response) in
            
            // -- put your code below this line
            
            if (response.result.isSuccess) {
                print("awesome, i got a response from the website!")
                
                do {
                    let json = try JSON(data:response.data!)
                    //var counter = 2
                    print(json)
                }
                catch {
                    print ("Error while parsing JSON response")
                }
                
            }
            
        }
    }
    
    func grabCategories(){
        for i in 1...43 {
            let URL = "https://api.bestbuy.com/v1/categories?apiKey=TWVhgdNpaxCG1GSk4IReKegI&pageSize=100&page=\(i)&show=name&format=json"
            // ALAMOFIRE function: get the data from the website
            Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
                (response) in
                
                // -- put your code below this line
                
                if (response.result.isSuccess) {
                    do {
                        let json = try JSON(data:response.data!)
                        //var counter = 2
                        print(json["categories"])
                    }
                    catch {
                        print ("Error while parsing JSON response")
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        print(image.size)
    }
    
    @IBAction func searchBtnClick(_ sender: Any) {
        //makeApiCall()
        grabCategories()
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
