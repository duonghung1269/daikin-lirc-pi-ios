//
//  DaikinService.swift
//  daikin-lirc-pi
//
//  Created by Dang Duong Hung on 13/8/17.
//  Copyright © 2017 Dang Duong Hung. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class DaikinService {
    
    public static func UpdateStates(state : DaikinModel, completionHandler: @escaping (Result<ResponseModel>) -> Void) -> Void {
        
        API.request(endpoint: API.Endpoints.UpdateStates(state)) { response in
            
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print(response.result.error!)
                completionHandler(.failure(response.result.error!))
                return
            }
            
            // make sure we got JSON and it's an array of dictionaries
            guard let json = response.result.value as? [String: AnyObject] else {
                print("didn't get todo objects as JSON from API")
                completionHandler(.failure(API.BackendError.objectSerialization(reason: "Did not get JSON object in response")))
                return
            }
            
            
            
            let responseModel = ResponseModel(json: json)
            completionHandler(.success(responseModel!))
        }
        
        
    }
    
}

