//
//  User.swift
//  BestBuyVision
//
//  Created by Xcode User on 2020-04-26.
//  Copyright © 2020 Rathin Chopra. All rights reserved.
//

import Foundation

class User {
    var userName: String
    var password: String
    var confirmPassword: String
    
    init(userName: String, password: String, confirmPassword: String) {
        self.userName = userName
        self.password = password
        self.confirmPassword = confirmPassword
    }
}
