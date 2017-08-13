//
//  DaikinModel.swift
//  daikin-lirc-pi
//
//  Created by Dang Duong Hung on 13/8/17.
//  Copyright © 2017 Dang Duong Hung. All rights reserved.
//

import Foundation

public class DaikinModel {
    
    var state : Bool
    var mode: String
    var temperature: Int
    var fan: String
    var swing: String
    var powerful: Bool
    
    init(state: Bool, mode: String, temperature: Int, fan: String, swing: String, powerful: Bool) {
        self.state = state;
        self.mode = mode;
        self.temperature = temperature;
        self.fan = fan;
        self.swing = swing;
        self.powerful = powerful;
    }
}

extension DaikinModel {
    func toJson() -> [String:Any] {
        return [
            "state" : state,
            "mode": mode,
            "temperature" : temperature,
            "fan" : fan,
            "swing": swing,
            "powerful": powerful
        ];
    }
    
    func getFanIndex() -> Int {
        switch fan {
        case "fan1":
            return 1
        case "fan2":
            return 2
        case "fan3":
            return 3
        case "fan4":
            return 4
        case "fan5":
            return 5
        case "auto":
            return 6
        case "moon-tree":
            return 7
        default:
            break
        }
        
        return 1
    }
    
    func clone() -> DaikinModel {
        return DaikinModel(state: state, mode: mode, temperature: temperature, fan: fan, swing: swing, powerful: powerful)
    }
}
