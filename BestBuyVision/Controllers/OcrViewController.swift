//
//  OcrViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-09-29.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Vision
import VisionKit
import MobileCoreServices

class OcrViewController: UIViewController, VNDocumentCameraViewControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    private var scanButton = ScanButton(frame: .zero)
    private var scanImageView = ScanImageView(frame: .zero)
    private var ocrTextView = OcrTextView(frame: .zero, textContainer: nil)
    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    private var webCode = ""
    private var SKU = Int()
    
    private var apiHandler = ApiHandlers()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.leftBarButtonItem?.isEnabled = true
        let backButtonImage = UIImage(systemName: "arrow.left")
        let bestbuyBtn = UIButton(type: .system)
        bestbuyBtn.setImage(backButtonImage, for: .normal)
        bestbuyBtn.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        bestbuyBtn.imageView?.contentMode = .scaleAspectFit
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: bestbuyBtn)
        
        bestbuyBtn.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        configure()
        configureOCR()
        // Do any additional setup after loading the view.
    }
    
    @objc private func backButton() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func configure() {
        view.addSubview(scanImageView)
        view.addSubview(ocrTextView)
        view.addSubview(scanButton)
        ocrTextView.isEditable = false
        ocrTextView.text = "NOTE: The image should contain the product tag with a SKU or webcode.\nMake sure the image is clear.\nTry to just take image of the product tag."
        ocrTextView.textColor = Colors.bestBuyBlue
        ocrTextView.font = UIFont.boldSystemFont(ofSize: 16.0)
        let padding: CGFloat = 16
        NSLayoutConstraint.activate([
            scanButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            scanButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            scanButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            scanButton.heightAnchor.constraint(equalToConstant: 50),
            
            ocrTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            ocrTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            ocrTextView.bottomAnchor.constraint(equalTo: scanButton.topAnchor, constant: -padding),
            ocrTextView.heightAnchor.constraint(equalToConstant: 200),
            
            scanImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            scanImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            scanImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            scanImageView.bottomAnchor.constraint(equalTo: ocrTextView.topAnchor, constant: -padding)
        ])
        scanButton.addTarget(self, action: #selector(scanDocument), for: .touchUpInside)
    }

    @objc private func scanDocument() {
        
        let imagePickerActionSheet =
          UIAlertController(title: "Snap/Upload Image",
                            message: nil,
                            preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
          let cameraButton = UIAlertAction(
            title: "Take Photo",
            style: .default) { (alert) -> Void in
              let imagePicker = UIImagePickerController()
              imagePicker.delegate = self
              imagePicker.sourceType = .camera
              imagePicker.mediaTypes = [kUTTypeImage as String]
              self.present(imagePicker, animated: true, completion: {
                self.showSpinner(onView: self.view)
              })
          }
          imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(
          title: "Choose Existing",
          style: .default) { (alert) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker, animated: true, completion: {
                self.showSpinner(onView: self.view)
            })
        }
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        
        present(imagePickerActionSheet, animated: true)
    }
    
    
    private func processImage(_ image: UIImage) {

        guard let cgImage = image.cgImage else { return }

        scanButton.isEnabled = false
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error)
        }
    }

    
    private func configureOCR() {
        ocrRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var ocrText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
                ocrText += topCandidate.string + "\n"
            }
            
            if(ocrText == ""){
                makeAlert.showAlert(controller: self, title: "Image Error", message: "Please select a image that contains text")
                DispatchQueue.main.async {
                    self.removeSpinner()
                    self.scanButton.isEnabled = true
                    self.scanImageView.image = nil
                }
                return
            }
            
            let pattern = "sku [0-9]{7}|sku[0-9]{7}|sku:[0-9]{7}|sku: [0-9]{7}"
            let text = ocrText.lowercased()
            let result = text.range(of: pattern, options:.regularExpression)
            
            var sku = ""
            if(result == nil){
                makeAlert.showAlert(controller: self, title: "Image Error", message: "Image is not clear.")
                DispatchQueue.main.async {
                    self.removeSpinner()
                    self.scanButton.isEnabled = true
                    self.scanImageView.image = nil
                }
                return
            }
            for i in text.indices[text.index(after: result!.lowerBound)..<result!.upperBound]{
                sku.append(text[i])
            }
        
            DispatchQueue.main.async {
                self.removeSpinner()
                self.scanButton.isEnabled = true
            }
            
            if(sku != ""){
                let stringArray = sku.components(separatedBy: CharacterSet.decimalDigits.inverted)
                var tempSKU = ""
                for item in stringArray {
                    if let number = Int(item) {
                        tempSKU += "\(number)"
                    }
                }
                if let number = Int(tempSKU) {
                    self.SKU = number
                }
                self.performSegue(withIdentifier: "segueProductWithSku", sender: self)
            }
            
        }
        
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.recognitionLanguages = ["en-US", "en-GB"]
        ocrRequest.usesLanguageCorrection = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
         didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      guard let selectedPhoto =
        info[.originalImage] as? UIImage else {
          dismiss(animated: true)
          return
      }
      dismiss(animated: true) {
        self.processImage(selectedPhoto)
        self.scanImageView.image = selectedPhoto
      }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        self.scanImageView.image = scan.imageOfPage(at: 0)
        processImage(scan.imageOfPage(at: 0))
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        //Handle properly error
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueProductWithSku" {
            if let productsTableViewController = segue.destination as? ProoductsTableViewController {
                productsTableViewController.productSKU = self.SKU
            }
        }
    }
}
    

