//
//  UIImage+Extension.swift
//  BygApp
//
//  Created by Prince Agrawal on 22/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

extension UIImageView {
    func setImageWithString(str: String) {
        
        //set background color to be white, image to nil
        image = nil
        backgroundColor = UIColor.whiteColor()
        
        var baseString = str
        //fetch 2 characters
        if (baseString.characters.count > 2) {
            let words = baseString.componentsSeparatedByString(" ")
            
            let firstLetter = words[0][words[0].startIndex]
            var secondLetter: Character?
            if words.count >= 2 {
                if((words[1] as NSString).length > 0) {
                    secondLetter = words[1][words[0].startIndex]
                }
                else if((words[0] as NSString).length > 0) {
                    secondLetter = words[0][words[0].startIndex.advancedBy(1)]
                }
            }
            else {
                if((words[0] as NSString).length > 0) {
                    secondLetter = words[0][words[0].startIndex.advancedBy(1)]
                }
            }
            
            if(secondLetter != nil) {
                baseString = "\(firstLetter)\(secondLetter!)"
            }
            else {
                baseString = "\(firstLetter)"
            }
        }
        else if(baseString.characters.count > 0) {
            baseString = baseString.substringToIndex(baseString.startIndex.advancedBy(1))
        }
        else {
            baseString = "X"
        }
        baseString = baseString.uppercaseString
        
        let tempView = UIView(frame: CGRectMake(0, 0, frame.width, frame.height))
        let nameLabel = UILabel(frame: CGRectMake(0, 0, frame.width, frame.height))
        nameLabel.text = baseString
        nameLabel.font = UIFont.BYGFont.Medium.fontWithSize(frame.height/2)
        nameLabel.textColor = UIColor.BYGColor.Default.colorWithAlpha(1.0)
        nameLabel.textAlignment = .Center
        tempView.addSubview(nameLabel)
        
        
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0)
        var outputImage : UIImage
        if let context = UIGraphicsGetCurrentContext() {
            CGContextClearRect(context, bounds)
            tempView.layer.renderInContext(context)
        }
        outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        image = outputImage
        
        nameLabel.removeFromSuperview()
    }
    
    func convertToGrayScale() {
        let imageRect:CGRect = CGRectMake(0, 0, self.image!.size.width, self.image!.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = self.image!.size.width
        let height = self.image!.size.height
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue)
        let context = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, colorSpace, bitmapInfo.rawValue)
        
        CGContextDrawImage(context, imageRect, self.image!.CGImage)
        let imageRef = CGBitmapContextCreateImage(context)
        let newImage = UIImage(CGImage: imageRef!)
        
        image = newImage
    }
}