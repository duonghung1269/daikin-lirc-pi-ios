//
//  DaikinModel.swift
//  daikin-lirc-pi
//
//  Created by Dang Duong Hung on 13/8/17.
//  Copyright © 2017 Dang Duong Hung. All rights reserved.
//

import Foundation

public class DaikinModel {
    
    var state : String
    var mode: String
    var temperature: Int
    var fan: String
    var swing: String
    var powerful: String
    
    init(state: String, mode: String, temperature: Int, fan: String, swing: String, powerful: String) {
        self.state = state;
        self.mode = mode;
        self.temperature = temperature;
        self.fan = fan;
        self.swing = swing;
        self.powerful = powerful;
    }
    
    init(json: [String: Any]?) {
        self.state = json?["powerState"] as? String ?? "off"
        self.mode = json?["mode"] as? String ?? "cool"
        self.temperature = json?["temperature"] as? Int ?? 25
        self.fan = json?["fan"] as? String ?? "fan1"
        self.swing = json?["swing"] as? String ?? "off"
        self.powerful = json?["powerful"] as? String ?? "off"
    }
    
    init() {
        self.state = "off"
        self.mode = "cool"
        self.temperature = 25
        self.fan = "fan1"
        self.swing = "off"
        self.powerful = "off"
    }
}

extension DaikinModel {
    func toModeIndex() -> Int {
        switch mode {
        case "dry":
            return 0
        case "cool":
            return 1
        case "fan":
            return 2
        default:
            break
        }
        
        return 1
    }
    
    func toModeString(index: Int) -> String {
        var mode = "cool"
        switch index {
        case 0:
            mode = "dry"
            break
        case 1:
            mode = "cool"
            break
        case 2:
            mode = "fan"
        default:
            break
        }

        return mode
    }
    
    func toFanIndex() -> Int {
        switch fan {
        case "fan1":
            return 0
        case "fan2":
            return 1
        case "fan3":
            return 2
        case "fan4":
            return 3
        case "fan5":
            return 4
        case "auto":
            return 5
        case "moon-tree":
            return 6
        default:
            return 0
        }
    }
    
    func toFanString(index: Int) -> String {
        var fan = "fan1"
        switch index {
        case 0:
            fan = "fan1"
            break
        case 1:
            fan = "fan2"
            break
        case 2:
            fan = "fan3"
            break
        case 3:
            fan = "fan4"
            break
        case 4:
            fan = "fan5"
            break
        case 5:
            fan = "auto"
            break
        case 6:
            fan = "moon-tree"
            break
        default:
            break
        }
        
        return fan
    }
    
    func toPowerStateBool() -> Bool {
        return state == "on"
    }
    
    func toPowerStateString(isOn: Bool) -> String {
        return isOn ? "on" : "off"
    }
    
    func toPowerfulBool() -> Bool {
        return powerful == "on"
    }
    
    func toPowerfulString(isOn: Bool) -> String {
        return isOn ? "on" : "off"
    }
    
    func toSwingBool() -> Bool {
        return swing == "on"
    }
    
    func toJson() -> [String:Any] {
        return [
            "powerState" : state,
            "mode": mode,
            "temperature" : temperature,
            "fan" : fan,
            "swing": swing,
            "powerful": powerful
        ];
    }
    
    func toWrappedJson() -> [[String:Any]] {
        return [[
            "powerState" : state,
            "mode": mode,
            "temperature" : temperature,
            "fan" : fan,
            "swing": swing,
            "powerful": powerful
        ]];
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
