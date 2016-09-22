//
//  NSError+BYG.swift
//  BygApp
//
//  Created by Prince Agrawal on 25/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

extension NSError {
    class func errorWithMessage(message: String)->NSError {
        let error = NSError(domain: "BYG", code: 401, userInfo: [message:message])
        return error
    }
}