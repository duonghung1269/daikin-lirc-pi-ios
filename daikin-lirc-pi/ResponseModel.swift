//
//  ResponseModel.swift
//  daikin-lirc-pi
//
//  Created by Dang Duong Hung on 13/8/17.
//  Copyright © 2017 Dang Duong Hung. All rights reserved.
//

import Foundation

public class ResponseModel : NSObject {
    
    var errorMessage : String
    var message: String
    var data: AnyObject
    
    required public init?(errorMessage: String, message: String, data: AnyObject) {
        self.errorMessage = errorMessage;
        self.message = message;
        self.data = data;
    }
    
    convenience init?(json: [String: Any]) {
        let errorMessage = json["errorMessage"] as! String
        let message = json["message"] as! String
        let data = json["Direction"] as AnyObject
        
        self.init(errorMessage: errorMessage, message: message, data: data)
    }
}
