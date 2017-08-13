//
//  API.swift
//  daikin-lirc-pi
//
//  Created by Dang Duong Hung on 13/8/17.
//  Copyright © 2017 Dang Duong Hung. All rights reserved.
//

import Foundation
import Alamofire

public class API {
    
    public static let baseURL: String = "http://localhost:3000"
    
    enum BackendError: Error {
        case objectSerialization(reason: String)
    }
    
    public enum Endpoints {
        case UpdateStates(DaikinModel)
        
        public var method: Alamofire.HTTPMethod {
            switch self {
            case .UpdateStates:
                return Alamofire.HTTPMethod.post
            }
        }
        
        public var path: String {
            switch self {
            case .UpdateStates(let _):
                return baseURL + "/remote/powerOn"
            }
        }
        
        public var parameters: [String : Any]? {
            var parameters = [String: Any]()
            switch self {
            case .UpdateStates(let daikinModel):
                parameters = daikinModel.toJson()
                break;
            }
            return parameters
        }
    }
    
    public static func request(
        endpoint: API.Endpoints,
        completionHandler: @escaping (DataResponse<Any>) -> Void)
        -> Request {
            
            let commonHeaders = ["Accept" : "application/json"]
            
            let request =  Alamofire.request(
                endpoint.path,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: JSONEncoding.default,
//                encoding: URLEncoding.default,
                headers: commonHeaders
                ).responseJSON { response in
                    debugPrint(response)
                    if (response.result.error) != nil {
                        completionHandler(response)
                    } else {
                        completionHandler(response)
                    }
            }
            return request
    }
}
