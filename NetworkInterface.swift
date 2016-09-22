//
//  NetworkInterface.swift
//  BygApp
//
//  Created by Prince Agrawal on 30/06/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation
import Alamofire

typealias JSONDictionary = [String:AnyObject]
typealias JSONArray = [JSONDictionary]
typealias APIServiceSuccessCallback = ((AnyObject?) -> ())
typealias APIServiceFailureCallback = ((NetworkErrorReason?, NSError?) -> ())
typealias JSONArrayResponseCallback = ((JSONArray?) -> ())
typealias JSONDictionaryResponseCallback = ((JSONDictionary?) -> ())

public enum NetworkMethod: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

public enum NetworkErrorReason: ErrorType {
    case FailureErrorCode(code: Int, message: String)
    case InternetNotReachable
    case UnAuthorizedAccess
    case Other
}

struct Resource {
    let method: NetworkMethod
    let parameters: [String : AnyObject]?
    let headers: [String:String]
}

protocol APIService {
    var path: String { get }
    var resource: Resource { get }
}

extension APIService {
    
    /**
     Method which needs to be called from the respective model class.
     - parameter successCallback:   successCallback with the JSON response.
     - parameter failureCallback:   failureCallback with ErrorReason, Error description and Error.
     */
    
    func request(isURLEncoded: Bool = false, success: APIServiceSuccessCallback, failure: APIServiceFailureCallback) {
        do {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            var encoding: ParameterEncoding = .JSON
            if resource.method == .GET || resource.method == .HEAD || isURLEncoded{
                encoding = .URLEncodedInURL
            }
            debugPrint("********************************* API Request **************************************")
            debugPrint("Request URL:\(path)")
            debugPrint("Request resource: \(resource)")
            debugPrint("************************************************************************************")
            Alamofire.request(alamofireMethodForMethod(resource.method), path, parameters: resource.parameters, encoding: encoding, headers: resource.headers)
                .validate()
                .responseJSON {
                    (response) -> Void in
                    debugPrint("********************************* API Response *************************************")
                    debugPrint("\(response.debugDescription)")
                    debugPrint("************************************************************************************")
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    switch response.result {
                    case .Success(let value):
                        success(value)
                    case .Failure(let error):
                        self.handleError(response, error: error, callback: failure)
                    }
            }
        }
    }
    
    func upload(fileData: NSData, success: APIServiceSuccessCallback, failure: APIServiceFailureCallback) {
        do {
            debugPrint("********************************* API Request **************************************")
            debugPrint("Request URL:\(path)")
            debugPrint("Request resource: \(resource)")
            debugPrint("************************************************************************************")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            Alamofire.upload(.POST, path,headers: resource.headers, multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: fileData, name: "image", fileName: "sampleimage.jpg", mimeType: "image/jpeg")
                }, encodingCompletion: { encodingResult in
                    debugPrint("********************************* Encoding Result **********************************")
                    debugPrint("\(encodingResult)")
                    debugPrint("************************************************************************************")

                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON(completionHandler: { (response) in
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            switch response.result {
                            case .Success(let value):
                                success(value)
                            case .Failure(let error):
                                self.handleError(response, error: error, callback: failure)
                            }
                            debugPrint("********************************* API Response *************************************")
                            debugPrint("\(response.debugDescription)")
                            debugPrint("************************************************************************************")
                        })
                    case .Failure(let encodingError):
                        debugPrint(encodingError)
                        let error = NSError(domain:"Network Error", code:-1, userInfo:["message":"\(encodingError)"])
                        self.handleError(nil, error: error, callback: failure)
                    }
            })
        }
    }
    
    private func alamofireMethodForMethod(method: NetworkMethod) -> Alamofire.Method{
        return Alamofire.Method(rawValue: method.rawValue)!
    }
    
    private func handleError(response: Response<AnyObject, NSError>?, error: NSError, callback:APIServiceFailureCallback) {
        if let errorCode = response?.response?.statusCode {
            guard let responseJSON = self.JSONFromData((response?.data)!) else {
                callback(NetworkErrorReason.FailureErrorCode(code: errorCode, message:""), error)
                debugPrint("Couldn't read the data")
                return
            }
            let message = responseJSON["err"] as? String ?? "Something went wrong. Please try again."
            callback(NetworkErrorReason.FailureErrorCode(code: errorCode, message: message), error)
        }
        else {
            let customError = NSError(domain: "Network Error", code: error.code, userInfo: error.userInfo)
            if let errorCode = response?.result.error?.code where errorCode == NSURLErrorNotConnectedToInternet {
            callback(NetworkErrorReason.InternetNotReachable, customError)
            }
            else {
                callback(NetworkErrorReason.Other, customError)
            }
        }
    }
    
    // Convert from NSData to json object
    private func JSONFromData(data: NSData) -> AnyObject? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        } catch let myJSONError {
            debugPrint(myJSONError)
        }
        return nil
    }
    
    // Convert from JSON to nsdata
    private func nsdataFromJSON(json: AnyObject) -> NSData?{
        do {
            return try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted)
        } catch let myJSONError {
            debugPrint(myJSONError)
        }
        return nil;
    }
    
}

