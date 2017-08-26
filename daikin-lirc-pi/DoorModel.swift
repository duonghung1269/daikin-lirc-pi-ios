//
//  DoorModel.swift
//  daikin-lirc-pi
//
//  Created by Dang Duong Hung on 24/8/17.
//  Copyright © 2017 Dang Duong Hung. All rights reserved.
//

import Foundation
public class DoorModel {
    
    var state : String
    
    init(state: String) {
        self.state = state;
    }
    
    init(json: [String: Any]?) {
        self.state = json?["command"] as? String ?? "lock"
    }
    
    init() {
        self.state = "lock"
    }
}

extension DoorModel {
    func toJson() -> [String:Any] {
        return [
            "command" : state,
                ];
    }
    
    func isLocked() -> Bool {
        return self.state == "lock"
    }
    
    func toggleDoorState() {
        if (self.state == "lock") {
            self.state = "unlock"
        } else {
            self.state = "lock"
        }
    }
}
