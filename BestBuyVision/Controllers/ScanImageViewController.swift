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
import CoreML
import Vision
import ImageIO

var productNameString = ""
var classificationResult = ""

class ScanImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let APIKEY = "TWVhgdNpaxCG1GSk4IReKegI"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var biggerimageView: UIImageView!
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
        biggerimageView.isHidden = true
        imageView.isHidden = false
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
    
    /*
    func grabCategories(){
        var categories:[String] = []
        var jsonConatiner:[String: String] = [:]
        for i in 1...43 {
            let URL = "https://api.bestbuy.com/v1/categories?apiKey=TWVhgdNpaxCG1GSk4IReKegI&pageSize=100&page=\(i)&show=name&format=json"
            // ALAMOFIRE function: get the data from the website
            Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
                (response) in
                
                // -- put your code below this line
                
                if (response.result.isSuccess) {
                    do {
                        let json = try JSON(data:response.data!)
                        print(json)
                    }
                    catch {
                        print ("Error while parsing JSON response")
                    }
                }
            }
        }
    }
    */
    
    // MARK: - Image Classification
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: Capstone_Image_Classifier().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func updateClassifications(for image: UIImage) {
        //classificationLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    // Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                //self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
        
            if classifications.isEmpty {
                //self.classificationLabel.text = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(1)
                topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    classificationResult = classification.identifier
                   //return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.biggerimageView.isHidden = false
                self.imageView.isHidden = true
                self.removeSpinner()
                self.performSegue(withIdentifier: "segueProducts", sender: AnyObject?.self)
                //print("Classification:\n" + descriptions.joined(separator: "\n"))
                //self.classificationLabel.text = "Classification:" + descriptions.joined(separator:)()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.showSpinner(onView: self.view)
        biggerimageView.image = image
        updateClassifications(for: image)
        
        guard (info[.editedImage] as? UIImage) != nil else {
            print("No image found")
            return
        }

        // print out the image size as a test
        print(image.size)
    }
    
    @IBAction func searchBtnClick(_ sender: AnyObject?) {
        //makeApiCall()
        //print("hello", productsData)
        //productNameString = productName.text!
        print(productNameString)
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
        //grabCategories()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueProducts" {
            if let productsTableViewController = segue.destination as? ProoductsTableViewController {
                productsTableViewController.productNameString = classificationResult
            }
        }
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
}
