//
//  ClassificationModels.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-07-26.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation
import UIKit
import CoreML

struct Category_Model {
    static let categoriesDict:[String:[String:AnyObject]] = [
                                        "Laptops":Laptops_Model.laptopsCategoriesDict,
                                        "Headphones":Laptops_Model.laptopsCategoriesDict,
                                        "Digital Camera": Laptops_Model.laptopsCategoriesDict,
                                        "In Ear Headphones": Laptops_Model.laptopsCategoriesDict,
                                        "Mobile_Phones": Laptops_Model.laptopsCategoriesDict,
                                        "Printers": Laptops_Model.laptopsCategoriesDict,
                                        "Tablets": Laptops_Model.laptopsCategoriesDict,
                                        "Watches": Laptops_Model.laptopsCategoriesDict]
}

struct Laptops_Model {
    static let laptopsCategoriesDict:[String:AnyObject] = ["Apple Inc.": AppleInc().model,
                                              "Acer Inc.": AcerInc().model,
                                              "ASUS": ASUS().model,
                                              "Dell": Dell().model,
                                              "Hewlett-Packard": Hewlett_Packard().model,
                                              "Lenovo": Lenovo().model,
                                              "Micro-Star International": Micro_Star_International().model,
                                              "Microsoft Corporation": MicrosoftCorporation().model,
                                              "Razer Inc.": RazerInc().model]
    
}
