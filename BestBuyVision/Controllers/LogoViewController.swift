//
//  LogoViewController.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-11-24.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreML
import Vision
import ImageIO

class LogoViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    var classificationResult: Array<String> = Array()
    var classificationConfidence: Array<Float> = Array()
    @IBOutlet weak var logoPickerView: UIPickerView!
    var image = UIImage()
    var selectedImageView = UIImageView()
    let cardViewForProduct = CardsUIView()
    var productcardUiView = UIView()
    var card1 = UIView()
    var companyName:String = ""
    var counter = 0
    var productCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productcardUiView = cardViewForProduct.getChildView()
        
        card1 = cardViewForProduct.createSubView(mainView: view, headerLabel: "Product Image", x_coordinate: Double((UIScreen.main.bounds.width - UIScreen.main.bounds.width * 0.9)/2), y_coordinate: Double(330), forMainMenuLogo: false, imageName: "camera")
        
        view.addSubview(card1)
        
        let tapGestureForProduct = UITapGestureRecognizer(target: self, action: #selector(clickProductView(_:)))
        tapGestureForProduct.delegate = self
        productcardUiView.addGestureRecognizer(tapGestureForProduct)

        // Do any additional setup after loading the view.
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
        classificationResult = Array()
        classificationConfidence = Array()
        image = UIImage()
        selectedImageView = UIImageView()
        counter = 0
        productcardUiView = UIView()
        companyName = ""
        //tabBarController?.navigationItem.leftBarButtonItem = nil;
    }
    
    @objc private func backButton() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func requirementBtnClick(_ sender: Any) {
        makeAlert.showAlert(controller: self, title: "Requirements for images used in recognition", message: "• The image for logo should only contain the logo that is shown on the product. \n • The image of the product should contain whole product and try to capture it in proper lighting. \n • Try to take an image in proper lighting so that the logo/product is properly visible and without any shadows.")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.cardViewForProduct.getProductImageView().image = image
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
            self.cardViewForProduct.getProductImageView().image = self.image
        }
    }
    
    @objc func clickProductView(_ sender: UIView) {
        
        var imageViewForProduct = cardViewForProduct.getProductImageView()
        
        //selectedImageView = imageViewForProduct
        cardViewForProduct.changeImageView()
        imageSelector()
    }
    
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
                
                if(self.classificationResult.contains("Negative Class") && self.classificationConfidence[ self.classificationResult.index(of: "Negative Class")!] > 0.01){
                    self.performSegue(withIdentifier: "segueNoClassifiedProductFoun", sender: nil)
                    return
                }
                else if(self.counter == 1){
                    
                    self.performSegue(withIdentifier: "segueProductsTableView", sender: self)
                    //self.cardView.revertImageView()
                    self.cardViewForProduct.revertImageView()
                    self.removeSpinner()
                }
                else if(self.counter == 0 && Category_Model.categoriesDict[self.classificationResult[0]]![self.companyName] != nil ){
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
    
    func ThirdClassificationRequest(modelName:String){
        counter = 1
        self.productCategory = modelName
        let thirdClassificationRequest: VNCoreMLRequest = {
            do {
                let chosenCategory = Category_Model.categoriesDict[modelName]!
                print(chosenCategory)
                         
                let chosenCategoryCompany = chosenCategory[companyName] as AnyObject
                 
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
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    @IBAction func searchProduct(_ sender: Any) {
        if(self.cardViewForProduct.getProductImageView().image == nil){
            makeAlert.showAlert(controller: self, title: "Image Error", message: "Please select the images")
            return
        }
        
        let productImage = self.cardViewForProduct.getProductImageView().image!
        self.showSpinner(onView: self.view)
        self.updateClassifications(for: productImage, requestName: self.classificationRequest)
        self.removeSpinner()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return companies.company[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.company.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        companyName = companies.company[row]
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueProductsTableView" {
            if let productsTableViewController = segue.destination as? ProoductsTableViewController {
                print(classificationResult)
                productsTableViewController.productNameStrings = classificationResult
                productsTableViewController.itemBrand = self.companyName
                productsTableViewController.productCategory = self.productCategory
            }
        }
    }
}
