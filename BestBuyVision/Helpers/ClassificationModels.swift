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
        "Headphones":Headphones_Model.headphonesCategoriesDict,
        "Digital Camera": Digital_Camera_Model.digitalCameraCategoriesDict,
        "In Ear Headphones": In_Ear_Headphones_Model.inEarHeadphonesCategoriesDict,
        "Mobile Phones": Mobile_Phones_Model.mobilePhoneCategoriesDict,
        "Printers": Printers_Model.printersCategoriesDict,
        "Tablets": Tablets_Model.tabletsCategoriesDict,
        "Watches": Watches_Model.watchCategoriesDict
    ]
}

struct Laptops_Model {
    static let laptopsCategoriesDict:[String:AnyObject] = [
          "Apple Inc.": AppleInc().model,
          "Acer Inc.": AcerInc().model,
          "ASUS": ASUS().model,
          "Dell": Dell().model,
          "Hewlett-Packard": Hewlett_Packard().model,
          "Lenovo": Lenovo().model,
          "Micro-Star International": Micro_Star_International().model,
          "Microsoft Corporation": MicrosoftCorporation().model,
          "Razer Inc.": RazerInc().model
    ]
}

struct Headphones_Model {
    static let headphonesCategoriesDict:[String:AnyObject] = [
        "Audio Technica": AudioTechinca().model,
        "Bang & Olufsen": BangAndOlufsen().model,
        "Beats Electronics": BeatsElectronics().model,
        "Bose Corporation": BoseCorporation().model,
        "Insignia": Insignia().model,
        "Jabra": Jabra().model,
        "JBL": JBL().model,
        "Sennheiser": Sennheiser().model,
        "Sony": Sony().model
    ]
}

struct Digital_Camera_Model {
    static let digitalCameraCategoriesDict:[String:AnyObject] = [
        "Nikon": Nikon().model,
        "Canon Inc.": CanonInc().model,
        "Sony": SonyDSLR().model
    ]
}

struct Tablets_Model {
    static let tabletsCategoriesDict:[String:AnyObject] = [
        "Apple Inc.": AppleTablets().model,
        "Microsoft Corporation": MicrosoftTablets().model,
        "Samsung Group": SamsungTablets().model
    ]
}

struct Printers_Model {
    static let printersCategoriesDict:[String:AnyObject] = [
        "Canon Inc.": CanonPrinters().model,
        "Hewlett-Packard": HpPrinters().model,
        "Seiko Epson": EpsonPrinters().model
    ]
}

struct Mobile_Phones_Model {
    static let mobilePhoneCategoriesDict:[String:AnyObject] = [
        "Apple Inc.": ApplePhones().model,
        "Samsung Group": SamsungPhones().model,
        "Google": GooglePhones().model
    ]
}

struct In_Ear_Headphones_Model {
    static let inEarHeadphonesCategoriesDict:[String:AnyObject] = [
        "Apple Inc.": AppleInEarHeadphones().model,
        "JBL": JBLInEarHeadphones().model,
        "Sony": SonyInEarHeadphones().model
    ]
}

struct Watches_Model {
    static let watchCategoriesDict:[String:AnyObject] = [
        "Apple Inc.": AppleWatch().model,
        "Fitbit": FitbitWatches().model,
        "Samsung Group": SamsungWatches().model
    ]
}

struct companies {
    static let company:[String] = ["", "Acer Inc.", "Apple Inc.", "ASUS", "Audio Technica", "Bang & Olufsen", "Beats Electronics", "Bose Corporation", "Canon Inc.", "Dell", "Fitbit", "Google", "Hewlett-Packard", "Insignia", "Jabra", "JBL", "Lenovo", "Micro-Star International", "Microsoft Corporation", "Nikon", "Razer Inc.", "Samsung Group", "Seiko Epson", "Sennheiser", "Sony"]
}
