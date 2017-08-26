//
//  DoorViewController.swift
//  daikin-lirc-pi
//
//  Created by Dang Duong Hung on 24/8/17.
//  Copyright © 2017 Dang Duong Hung. All rights reserved.
//

import UIKit
import Firebase

class DoorViewController: UIViewController {

    @IBOutlet weak var btnDoorState: UIButton!
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblCurrentState: UILabel!
    var ref: DatabaseReference!
    var _doorModel = DoorModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // for real time update
        ref.child("door_event").observe(DataEventType.value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? [String : Any]
            self._doorModel = self.initModelFromJson(json: value)
            self.firstTimePopulateUI(model: self._doorModel)
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    func initModelFromJson(json: [String: Any]?) -> DoorModel {
        if (json != nil) {
            let model = DoorModel(json: json)
            return model
        }
        
        // return default
        return DoorModel();
    }
    
    func firstTimePopulateUI(model: DoorModel) {
        updateBtnDoorState(model: model)
    }

    func updateBtnDoorState(model: DoorModel) {
        if (model.isLocked()) {
            let image = UIImage(named: "DoorLock") as UIImage?
            btnDoorState.setImage(image, for: .normal)
            lblMessage.text = "Tap to UNLOCK!";
//            lblCurrentState.text = "Door Locked!"
        } else {
            let image = UIImage(named: "DoorUnlock") as UIImage?
            btnDoorState.setImage(image, for: .normal)
            lblMessage.text = "Tap to LOCK!";
//            lblCurrentState.text = "Door Unlocked!"
        }
    }
    
    func updateRemoteDoorState(model: DoorModel){
        let json = model.toJson()
        print(json)
        let childUpdate = ["door_event" : json]
        print(childUpdate)
        self.ref.updateChildValues(childUpdate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnDoorClick(_ sender: Any) {
        _doorModel.toggleDoorState()
        updateRemoteDoorState(model: _doorModel)
        updateBtnDoorState(model: _doorModel)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
