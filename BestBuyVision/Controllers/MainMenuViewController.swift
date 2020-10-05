//
//  MainMenuViewController.swift
//  BestBuyVision
//
//  Created by Rathin Chopra on 2020-10-02.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController, UIGestureRecognizerDelegate {

    let cardViewForTextRecognition = CardsUIView()
    let cardViewForImageRecognition = CardsUIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cardUiView = cardViewForTextRecognition.getChildView()
        let cardUiViewForImageRecognition = cardViewForImageRecognition.getChildView()
        
        let card1 = cardViewForTextRecognition.createSubView(mainView: view, headerLabel: "Image of the logo", x_coordinate: Double(UIScreen.main.bounds.width * 0.045), y_coordinate: Double(30), forMainMenuLogo: true)
        
        let card2 = cardViewForImageRecognition.createSubView(mainView: view, headerLabel: "Image of the logo", x_coordinate: Double((UIScreen.main.bounds.width * 0.5)), y_coordinate: Double(30), forMainMenuLogo: true)
        
        view.addSubview(card1)
        view.addSubview(card2)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickView(_:)))
        tapGesture.delegate = self
        cardUiView.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.hidesBackButton = true
        setUpNavigationBar()
    }
    
    @objc func clickView(_ sender: UIView) {
        
        print("image clicked")
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
