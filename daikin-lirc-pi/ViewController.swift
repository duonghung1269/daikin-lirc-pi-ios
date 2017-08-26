//
//  ViewController.swift
//  daikin-lirc-pi
//
//  Created by Dang Duong Hung on 13/8/17.
//  Copyright © 2017 Dang Duong Hung. All rights reserved.
//

import UIKit
import MTCircularSlider
import Intents
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var segmentFan: UISegmentedControl!
    @IBOutlet weak var btnPowerOff: UIButton!
    @IBOutlet weak var SwitchPowerful: UISwitch!
    @IBOutlet weak var SwitchSwing: UISwitch!
    @IBOutlet weak var LblFanValue: UILabel!
    @IBOutlet weak var LblTemperatureValue: UILabel!

    @IBOutlet weak var SegmentMode: UISegmentedControl!
    
    @IBOutlet weak var CircularSliderTemp: MTCircularSlider!
    @IBOutlet weak var ViewHidePanel: UIView!
    var _daikinModel = DaikinModel()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = Database.database().reference()
        
        btnPowerOff.isHidden = true
        
        INPreferences.requestSiriAuthorization { (status) in
            
        }
        
        INVocabulary.shared().setVocabularyStrings(["push up", "sit up", "pull up"], of: .workoutActivityName)
        
//        ref.child("last_event").observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? [String : Any]
//            self._daikinModel = self.initModelFromJson(json: value)
//            self.firstTimePopulateUI(model: self._daikinModel)            
//        }) { (error) in
//            print(error.localizedDescription)
//        }
        
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appDidBecomeActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // for real time update
        ref.child("last_event").observe(DataEventType.value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? [String : Any]
            self._daikinModel = self.initModelFromJson(json: value)
            self.firstTimePopulateUI(model: self._daikinModel)
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func appDidBecomeActive() {
        if (AppDelegate.intentStart == nil) {
            return
        } else if (AppDelegate.intentStart == true) {
            btnPowerOnClick(btnPowerOff)
            AppDelegate.intentStart = nil
        } else {
            powerValueChanged(isOn: false)
            sendRemoteStates()
            AppDelegate.intentStart = nil
        }

    }
    
    func firstTimePopulateUI(model: DaikinModel) {
        powerValueChanged(isOn: model.toPowerStateBool())
        SegmentMode.selectedSegmentIndex = model.toModeIndex()
        CircularSliderTemp.value = Float(model.temperature)
        updateLableTemperature(temperature: model.temperature)
        segmentFan.selectedSegmentIndex = model.toFanIndex()
        SwitchSwing.setOn(model.toSwingBool(), animated: false)
        SwitchPowerful.setOn(model.toPowerfulBool(), animated: false)
    }
    
    func powerValueChanged(isOn : Bool) {
        _daikinModel.state = _daikinModel.toPowerStateString(isOn: isOn)
        UIView.animate(withDuration: 1, animations: {
            self.ViewHidePanel.alpha = isOn ? 0 : 1
            self.ViewHidePanel.isHidden  = isOn
            
            self.btnPowerOff.alpha = isOn ? 1 : 0;
            self.btnPowerOff.isHidden = !isOn
        })
    }
    
    @IBAction func SegmentModeValueChanged(_ sender: Any) {
        let index = SegmentMode.selectedSegmentIndex
        let mode = _daikinModel.toModeString(index: index)
        
        _daikinModel.mode = mode
        sendRemoteStates()
    }
    @IBAction func SwitchSwingValueChanged(_ sender: Any) {
        _daikinModel.swing = SwitchSwing.isOn ? "on" : "off";
        sendRemoteStates()
    }
    @IBAction func SliderFanValueChanged(_ sender: Any) {
        
    }
    
    @IBAction func SwitchPowerfulValueChanged(_ sender: Any) {
        _daikinModel.powerful = _daikinModel.toPowerfulString(isOn: SwitchPowerful.isOn)
        sendRemoteStates()
    }
    
    func initModelFromJson(json: [String: Any]?) -> DaikinModel {
        if (json != nil) {
            let model = DaikinModel(json: json)
            return model
        }
        
        // return default
        return DaikinModel();
    }
    
    func sendRemoteStates(){
        let json = _daikinModel.toJson()
        print(json)
        let childUpdate = ["last_event" : json]
        print(childUpdate)
        self.ref.updateChildValues(childUpdate)
    }
    
    
    
    @IBAction func CircularSliderTemperatureValueChanged(_ sender: Any) {
        let daikinModel = _daikinModel.clone();
        let temperature = Int(CircularSliderTemp.value)
        print("oldTemp=\(daikinModel.temperature), newTemp=\(temperature)")
        if (daikinModel.temperature == temperature) {
            return
        }

        _daikinModel.temperature = temperature
        updateLableTemperature(temperature: temperature)
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.sendRemoteStates), object: nil)
        self.perform(#selector(self.sendRemoteStates), with: nil, afterDelay: 0.5)
    }
    
    func updateLableTemperature(temperature: Int) {
        LblTemperatureValue.text = "\(temperature) °C"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func segmentFanValueChanged(_ sender: Any) {
        let value = Int(segmentFan.selectedSegmentIndex)
        let fan = _daikinModel.toFanString(index: value)
        _daikinModel.fan = fan
        sendRemoteStates()
    }
    
    @IBAction func btnPowerOnClick(_ sender: Any) {
        powerValueChanged(isOn: true);
        sendRemoteStates()
    }
    @IBAction func btnPowerOffClick(_ sender: Any) {
        powerValueChanged(isOn: false);
        sendRemoteStates()
    }

}

