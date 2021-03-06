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

class ScanImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {

    var productNameString = ""
    var classificationResult: Array<String> = Array()
    var classificationConfidence: Array<Float> = Array()
    var image = UIImage()
    var imageForProduct = UIImage()
    var selectedImageView = UIImageView()
    var selectedImageViewForProduct = UIImageView()
    var counter = 0
    let APIKEY = "TWVhgdNpaxCG1GSk4IReKegI"
    var cardUiView = UIView()
    let cardView = CardsUIView()
    let cardViewForProduct = CardsUIView()
    var productcardUiView = UIView()
    var companylogoName:String = ""
    var card1 = UIView()
    var card2 = UIView()
    var productCategory = ""
    var senderName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        //setUpNavigationBar()
        
        /*
        let backButtonImage = UIImage(systemName: "arrow.left")
        let bestbuyBtn = UIButton(type: .system)
        bestbuyBtn.setImage(backButtonImage, for: .normal)
        bestbuyBtn.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        bestbuyBtn.imageView?.contentMode = .scaleAspectFit
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: bestbuyBtn)
        bestbuyBtn.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = true
        */
        
        cardUiView = cardView.getChildView()
        productcardUiView = cardViewForProduct.getChildView()
        
        card1 = cardView.createSubView(mainView: view, headerLabel: "Product Logo", x_coordinate: Double((UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.9)/2), y_coordinate: Double(30), forMainMenuLogo: false, imageName: "camera")
        
        card2 = cardViewForProduct.createSubView(mainView: view, headerLabel: "Product Image", x_coordinate: Double((UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.9)/2), y_coordinate: Double(270), forMainMenuLogo: false, imageName: "camera")
        
        view.addSubview(card1)
        view.addSubview(card2)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickView(_:)))
        tapGesture.delegate = self
        cardUiView.addGestureRecognizer(tapGesture)
        
        let tapGestureForProduct = UITapGestureRecognizer(target: self, action: #selector(clickProductView(_:)))
        tapGestureForProduct.delegate = self
        productcardUiView.addGestureRecognizer(tapGestureForProduct)
        //uploadImageBtn.layer.cornerRadius = uploadImageBtn.frame.size.height/2
    }
    
    private func setUpNavigationBar() {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "Logo2")
        let newImage = image?.imageWithColor(.white)
        imageView.image = newImage
        navigationItem.titleView = imageView
        
        tabBarController?.navigationController?.navigationBar.barTintColor = Colors.bestBuyBlue
        tabBarController?.navigationController?.navigationBar.tintColor = Colors.white
        
        let accountImage = UIImage(systemName: "person.circle")
        
        let bestbuyBtn = UIButton(type: .system)
        bestbuyBtn.setImage(accountImage, for: .normal)
        bestbuyBtn.imageView?.contentMode = .scaleAspectFit
        bestbuyBtn.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bestbuyBtn)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        productNameString = ""
        classificationResult = Array()
        classificationConfidence = Array()
        image = UIImage()
        selectedImageView = UIImageView()
        selectedImageViewForProduct = UIImageView()
        counter = 0
        cardUiView = UIView()
        productcardUiView = UIView()
        companylogoName = ""
        //senderName = ""
        //tabBarController?.navigationItem.leftBarButtonItem = nil;
    }
    
    private func companyLogoDetector(image: UIImage, completion: @escaping (String?) -> ()){
        var googleResult:String = ""
        
        GoogleVisionLogoDetector().detect(from: image) { companyName in
             do {
                let json = try JSON(data:companyName!)
                googleResult = json["responses"][0]["logoAnnotations"][0]["description"].stringValue
                if (googleResult == ""){
                    makeAlert.showAlert(controller: self, title: "Product Logo Error", message: "Could not find logo name. Please take the image of product logo properly.")
                    self.cardViewForProduct.getProductImageView().image = UIImage()
                    self.cardView.getProductImageView().image = UIImage()
                    self.cardView.revertImageView()
                    self.cardViewForProduct.revertImageView()
                    completion("Error")
                    return
                }
                self.companylogoName = googleResult
                completion(googleResult)
             } catch {
                 return
             }
        }
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
            request.imageCropAndScaleOption = .scaleFit
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func updateClassifications(for image: UIImage, requestName: VNCoreMLRequest) {
        //classificationLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
        guard let ciImage = CIImage(image: image) else {
            makeAlert.showAlert(controller: self, title: "ERROR!", message: "Image for the logo is not clear.")
            return
        }
        
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
    
    @IBAction func requuirementsBtnClick(_ sender: Any) {
        makeAlert.showAlert(controller: self, title: "Requirements for images used in recognition", message: "• The image for logo should only contain the logo that is shown on the product. \n • The image of the product should contain whole product and try to capture it in proper lighting. \n • Try to take an image in proper lighting so that the logo/product is properly visible and without any shadows.")
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
                let topClassifications = classifications.prefix(5)
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
                
                //self.biggerimageView.isHidden = false
                //self.imageView.isHidden = true
                //self.removeSpinner()
                print(self.classificationResult)
                if(self.classificationResult.contains("Negative Class") && self.classificationConfidence[ self.classificationResult.index(of: "Negative Class")!] > 0.01){
                    self.performSegue(withIdentifier: "segueNegativeClass", sender: nil)
                    return
                }
                else if(self.counter == 1){
                    
                    self.performSegue(withIdentifier: "segueProducts", sender: self)
                    self.cardView.revertImageView()
                    self.cardViewForProduct.revertImageView()
                    self.removeSpinner()
                }
                else if(self.counter == 0 && Category_Model.categoriesDict[self.classificationResult[0]]![self.companylogoName] != nil ){
                    self.ThirdClassificationRequest(modelName: self.classificationResult[0])
                }
                else{
                    makeAlert.showAlert(controller: self, title: "No related product", message: "Could not find the product with the associated company.")
                }
                //print("Classification:\n" + descriptions.joined(separator: "\n"))
                //self.classificationLabel.text = "Classification:" + descriptions.joined(separator:)()
            }
        }
    }
    
    func ThirdClassificationRequest(modelName:String){
        counter = 1
        self.productCategory = modelName
        let thirdClassificationRequest: VNCoreMLRequest = {
            do {
                let chosenCategory = Category_Model.categoriesDict[modelName]!
                         
                let chosenCategoryCompany = chosenCategory[companylogoName] as AnyObject
                 
                let model = try VNCoreMLModel(for: chosenCategoryCompany as! MLModel)
                
                let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                    self?.processClassifications(for: request, error: error)
                })
                request.imageCropAndScaleOption = .scaleFit
                return request
                } catch {
                    fatalError("Failed to load Vision ML model: \(error)")
                }
            }()
            
            updateClassifications(for: image, requestName: thirdClassificationRequest)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if(self.senderName == "logo"){
            self.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            //self.selectedImageView.image = self.image
            cardView.getProductImageView().image = self.image
        }
        else if(self.senderName == "product"){
            self.imageForProduct = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            self.cardViewForProduct.getProductImageView().image = self.imageForProduct
        }
        
        //selectedImageView.image = image
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
            if(self.senderName == "logo"){
                self.cardView.getProductImageView().image = self.image
            }
            else if(self.senderName == "product"){
                self.cardViewForProduct.getProductImageView().image = self.imageForProduct
            }
        }
    }

    @objc func clickView(_ sender: UIView) {
        
        var imageViewForProduct = cardView.getProductImageView()
        self.senderName = "logo"
        //selectedImageView = imageViewForProduct
        cardView.changeImageView()
        imageSelector()
    }
    
    
    @objc func clickProductView(_ sender: UIView) {
        
        var imageViewForProduct = cardViewForProduct.getProductImageView()
        self.senderName = "product"
        //selectedImageViewForProduct = imageViewForProduct
        cardViewForProduct.changeImageView()
        imageSelector()
    }
    
    @objc private func backButton() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func searchProductClick(_ sender: Any) {
        if(self.cardView.getProductImageView().image == nil || self.cardViewForProduct.getProductImageView().image == nil){
            makeAlert.showAlert(controller: self, title: "Image Error", message: "Please select both the images")
            return
        }
        
        let logoImage = self.cardView.getProductImageView().image!
        let productImage = self.cardViewForProduct.getProductImageView().image!
    
        self.showSpinner(onView: self.view)
        self.companyLogoDetector(image: logoImage){ googleResult in
            
            if(googleResult == "Error"){
                self.removeSpinner()
                return
            }
            
            self.companylogoName = googleResult!
            self.updateClassifications(for: productImage, requestName: self.classificationRequest)
            
            self.removeSpinner()
        }
        
       
    }
    
    @IBAction func noLogoFoundClick(_ sender: Any) {
        self.performSegue(withIdentifier: "segueNoLogo", sender: self)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueProducts" {
            if let productsTableViewController = segue.destination as? ProoductsTableViewController {
                print(classificationResult)
                productsTableViewController.productNameStrings = classificationResult
                productsTableViewController.itemBrand = self.companylogoName
                productsTableViewController.productCategory = self.productCategory
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
