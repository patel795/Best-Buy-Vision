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

class ScanImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var productNameString = ""
    var classificationResult: Array<String> = Array()
    var classificationConfidence: Array<Float> = Array()
    var image = UIImage()
    var selectedImageView = UIImageView()
    var counter = 0
    let APIKEY = "TWVhgdNpaxCG1GSk4IReKegI"

    @IBOutlet weak var productLogoImage: UIImageView!
    @IBOutlet weak var uploadImageBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var biggerimageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadImageBtn.layer.cornerRadius = uploadImageBtn.frame.size.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        biggerimageView.isHidden = true
        imageView.isHidden = false
        self.tabBarController?.navigationItem.hidesBackButton = true
        setUpNavigationBar()
    }
    
    private func detectBoundingBoxes(for image: UIImage) {
      GoogleVisionLogoDetector().detect(from: image) { ocrResult in
        //self.activityIndicator.stopAnimating()
        guard let ocrResult = ocrResult else {
          fatalError("Did not recognize any text in this image")
        }
        print(ocrResult)
        self.performSegue(withIdentifier: "segueProducts", sender: AnyObject?.self)
      }
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
    
    // MARK: - Image Classification
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: First_Stage_Categories_Classifier().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func updateClassifications(for image: UIImage, requestName: VNCoreMLRequest) {
        //classificationLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([requestName])
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
                let topClassifications = classifications.prefix(10)
                self.classificationResult = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    //classificationResult = classification.identifier
                    
                    return String(format: "%@", classification.identifier)
                }
                
                self.classificationConfidence = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    //classificationResult = classification.identifier
                    
                    return classification.confidence as Float
                    //String(format: "%@", classification.confidence)
                }
                
                self.biggerimageView.isHidden = false
                self.imageView.isHidden = true
                self.removeSpinner()
                
                if(self.classificationResult.contains("Negative Class") && self.classificationConfidence[ self.classificationResult.index(of: "Negative Class")!] > 0.01){
                    self.performSegue(withIdentifier: "segueNegativeClass", sender: nil)
                    return
                }
                
                if(self.counter == 1){
                    self.performSegue(withIdentifier: "segueProducts", sender: AnyObject?.self)
                }
                
                if(self.counter == 0){
                    self.secondClassificationRequest(modelName: self.classificationResult[0])
                }
                //print("Classification:\n" + descriptions.joined(separator: "\n"))
                //self.classificationLabel.text = "Classification:" + descriptions.joined(separator:)()
            }
        }
    }
    
    func secondClassificationRequest(modelName:String){
        counter = 1
    
        let secondClassificationRequest: VNCoreMLRequest = {
            do {
                /*
                 Use the Swift class `MobileNet` Core ML generates from the model.
                 To use a different Core ML classifier model, add it to the project
                 and replace `MobileNet` with that model's generated Swift class.
                 */
                
                print("Testing")
                let catergoriesDict:[String:AnyObject] = ["Laptops":Laptops().model, "Headphones":Laptops().model,
                    "Digital Camera": Laptops().model,
                    "In Ear Headphones": Laptops().model,
                    "Mobile Phones": Laptops().model,
                    "Printers": Laptops().model,
                    "Tablets": Laptops().model,
                    "Watches": Laptops().model]
                
                let chosenCategory = catergoriesDict[modelName]!
                
                let model = try VNCoreMLModel(for: chosenCategory as! MLModel)
                
                let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                    self?.processClassifications(for: request, error: error)
                })
                request.imageCropAndScaleOption = .centerCrop
                return request
            } catch {
                fatalError("Failed to load Vision ML model: \(error)")
            }
        }()
        
        updateClassifications(for: image, requestName: secondClassificationRequest)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        selectedImageView.image = image
        //self.showSpinner(onView: self.view)
        
        //self.removeSpinner()
        
        //detectBoundingBoxes(for: image)
        //updateClassifications(for: image, requestName: classificationRequest)
        
        guard (info[.editedImage] as? UIImage) != nil else {
            return
        }

        // print out the image size as a test
        print(image.size)
    }
    
    @IBAction func productLogoBtnClick(_ sender: Any) {
    }
    
    @IBAction func searchBtnClick(_ sender: AnyObject?) {
        
        selectedImageView = biggerimageView
        biggerimageView.isHidden = false
        imageSelector()
        
    }
    
    // MARK: - Private Functions
    
    private func imageSelector(){
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

        present(photoSourcePicker, animated: true){
            self.biggerimageView.image = self.image
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueProducts" {
            if let productsTableViewController = segue.destination as? ProoductsTableViewController {
                productsTableViewController.productNameStrings = classificationResult
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
