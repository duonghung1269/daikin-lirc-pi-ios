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

class ViewController: UIViewController {
    @IBOutlet weak var SwitchPower: UISwitch!

    @IBOutlet weak var SwitchPowerful: UISwitch!
    @IBOutlet weak var SwitchSwing: UISwitch!
    @IBOutlet weak var LblFanValue: UILabel!
    @IBOutlet weak var SliderFan: UISlider!
    @IBOutlet weak var LblTemperatureValue: UILabel!

    @IBOutlet weak var SegmentMode: UISegmentedControl!
    
    @IBOutlet weak var CircularSliderTemp: MTCircularSlider!
    @IBOutlet weak var ViewHidePanel: UIView!
    var _daikinModel : DaikinModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        INPreferences.requestSiriAuthorization { (status) in
            
        }
        
        INVocabulary.shared().setVocabularyStrings(["push up", "sit up", "pull up"], of: .workoutActivityName)

        
        _daikinModel = initStates()        
        SliderFan.isContinuous = false;
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appDidBecomeActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
            }
    
    func appDidBecomeActive() {
        if (AppDelegate.intentStart == nil) {
            return
        } else if (AppDelegate.intentStart == true) {
            SwitchPower.setOn(true, animated: true)
            SwitchPowerValueChanged(SwitchPower);
            AppDelegate.intentStart = nil
        } else {
            SwitchPower.setOn(false, animated: true)
            SwitchPowerValueChanged(SwitchPower);
            AppDelegate.intentStart = nil
        }

    }
    
    @IBAction func SwitchPowerValueChanged(_ sender: Any) {
        _daikinModel.state = SwitchPower.isOn
        updateRemoteStates()
        UIView.animate(withDuration: 1, animations: {
            self.ViewHidePanel.alpha = self.SwitchPower.isOn ? 0 : 1
            self.ViewHidePanel.isHidden  = self.SwitchPower.isOn
        })
    }
    @IBAction func SegmentModeValueChanged(_ sender: Any) {
        let index = SegmentMode.selectedSegmentIndex
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
        
        _daikinModel.mode = mode
        updateRemoteStates()
    }
    @IBAction func SwitchSwingValueChanged(_ sender: Any) {
        _daikinModel.swing = SwitchSwing.isOn ? "on" : "off";
        updateRemoteStates()
    }
    @IBAction func SliderFanValueChanged(_ sender: Any) {
        let value = Int(SliderFan.value)
        if (value == _daikinModel.getFanIndex()) {
            return
        }
        
        var fan = "fan1"
        var displayValue = "Level 1"
        switch value {
        case 1:
            fan = "fan1"
            displayValue = "Level 1"
            break
        case 2:
            fan = "fan2"
            displayValue = "Level 2"
            break
        case 3:
            fan = "fan3"
            displayValue = "Level 3"
            break
        case 4:
            fan = "fan4"
            displayValue = "Level 4"
            break
        case 5:
            fan = "fan5"
            displayValue = "Level 5"
            break
        case 6:
            fan = "auto"
            displayValue = "Auto"
            break
        case 7:
            fan = "moon-tree"
            displayValue = "Moon Tree"
            break
        default:
            break
        }
        
        LblFanValue.text = displayValue
        _daikinModel.fan = fan
        updateRemoteStates()
        
    }
    
    @IBAction func SwitchPowerfulValueChanged(_ sender: Any) {
        _daikinModel.powerful = SwitchPowerful.isOn
        updateRemoteStates()
    }
    
    func initStates() -> DaikinModel {
        let daikinModel = DaikinModel(state: false, mode: "cool", temperature: 22, fan: "fan1", swing: "on", powerful: false);
        
        return daikinModel;
    }
    
    func updateRemoteStates(){
        DaikinService.UpdateStates(state: _daikinModel) { response in
            if (response.error != nil) {
                print(response.description)
            } else {
                print(response.isSuccess)
            }
        }
    }
    
    
    
    @IBAction func CircularSliderTemperatureValueChanged(_ sender: Any) {
        let daikinModel = _daikinModel.clone();
        let temperature = Int(CircularSliderTemp.value)
        print("oldTemp=\(daikinModel.temperature), newTemp=\(temperature)")
        if (daikinModel.temperature == temperature) {
            return
        }

        _daikinModel.temperature = temperature
        
//        updateRemoteStates()
        LblTemperatureValue.text = "\(temperature) °C"
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.updateRemoteStates), object: nil)
        self.perform(#selector(self.updateRemoteStates), with: nil, afterDelay: 0.5)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

