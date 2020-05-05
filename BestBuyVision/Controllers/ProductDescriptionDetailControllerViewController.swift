//
//  ProductDescriptionDetailControllerViewController.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-04-30.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ImageSlideshow

class ProductDescriptionDetailControllerViewController: UIViewController, ImageSlideshowDelegate{
    
    let APIKEY = "TWVhgdNpaxCG1GSk4IReKegI"
    var SKU = ""
    var indexPathRow = Int()
    var imageLinks: Array<String> = Array()
    var products =  [Product]()
    var imagesJson: JSON?
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    var alamofireSource = [AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeApiCall(){ (info) in
            self.alamofireSource.removeAll()
            
            for i in 0...((self.imagesJson?.count ?? 1)-1) {
                let string = self.imagesJson?[i]["rel"].stringValue
                if (string?.contains("Standard"))! {
                    self.alamofireSource.append(AlamofireSource(urlString: (self.imagesJson?[i]["href"].stringValue)!)!)
                }
                //self.imageLinks.append(json["products"][0]["images"][i]["href"].stringValue)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    private func imageSlideView(){

        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill

        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        slideshow.pageIndicator = pageControl

        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self

        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow.setImageInputs(alamofireSource)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ProductDescriptionDetailControllerViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)
    }
    
    @objc func didTap() {
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        
    }
    
    // MARK: - Making API call
    private func makeApiCall(completion: @escaping (String) -> ()){
        
        guard let URL = URL(string:
            "https://api.bestbuy.com/v1/products(sku=\(self.SKU))?show=sku,name,salePrice,images,shortDescription&apiKey=\(self.APIKEY)&format=json")
            
        else {
            completion("Error: URL")
            return
        }
        DispatchQueue.main.async {
            //showing loading spinner
            self.showSpinner(onView: self.view)
        }
        
        // ALAMOFIRE function: get the data from the website
        Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
            (response) in
            if (response.result.isSuccess) {
                do {
                    let json = try JSON(data:response.data!)
                    if(json["error"].isEmpty){
                        let item = Product(productName: json["products"][0]["name"].stringValue,
                                               productPrice: json["products"][0]["salePrice"].stringValue,
                                               productDescription: json["products"][0]["shortDescription"].stringValue,
                                               SKU: json["products"][0]["sku"].stringValue,
                                               productThumbnailURL: json["products"][0]["image"].stringValue)
                        
                        self.imagesJson = json["products"][0]["images"]
                        self.products.append(item)
                        
                        print(self.products)
                        self.productName.text = item.productName
                        self.productPrice.text = "$" + item.productPrice
                        
                        DispatchQueue.main.async {
                            //reloading the table view data
                            //self.tableView.reloadData()
                            self.imageSlideView()
                            // remove spinner
                            self.removeSpinner()
                        }
                        
                        completion("Success")
                    }
                    else{
                        self.removeSpinner()
                        self.performSegue(withIdentifier: "segueNoProduct", sender: nil)
                        completion("Can't find the product.")
                    }
                }
                catch {
                    completion("Error while parsing JSON response")
                }
            }
            else{
                // remove spinner
                self.removeSpinner()
                self.performSegue(withIdentifier: "segueNoProduct", sender: nil)
                completion("Request Failed")
            }
        }
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
