//
//  SettingsViewController.swift
//  daikin-lirc-pi
//
//  Created by Dang Duong Hung on 26/8/17.
//  Copyright © 2017 Dang Duong Hung. All rights reserved.
//

import UIKit
import CoreLocation.CLLocationManagerDelegate
import UserNotifications

struct PreferencesKeys {
    static let savedItem = "savedItem"
}

class GeotificationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfRadius: UITextField!
    @IBOutlet weak var tfLongitude: UITextField!
    @IBOutlet weak var tfLatitude: UITextField!
    
    var locationManager: CLLocationManager!
    var _didStartMonitoringRegion : Bool!
    let DEFAULT_LATITUDE : Double = 1.3179614
    let DEFAULT_LONGITUDE : Double = 103.9094137
    let DEFAULT_RADIUS : Double = 300
    let DEFAULT_NOTE : String = "Smart Room"
    let DEFAULT_IDENTIFIER : String = "SmartRoom"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Location Manager
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        _didStartMonitoringRegion = false
        
        self.hideKeyboardWhenTappedAround()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 1. status is not determined
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            // 2. authorization were denied
        else if CLLocationManager.authorizationStatus() == .denied {
            print("Location services were previously denied. Please enable location services for this app in Settings.")
        }
            // 3. we do have authorization
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
        
        loadGeotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnUpdateClick(_ sender: Any) {
        let lat = Double(tfLatitude.text!)!
        let long = Double(tfLongitude.text!)!
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        let radius = Double(tfRadius.text!)!
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let identifier = "SmartRoom"
        let note = tfNote.text ?? ""
        
        let geo = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note)
        self.stopMonitoring(geotification: geo)
        self.startMonitoring(geotification: geo)
        
        saveGeotification(geotification: geo)
    }
    
    @IBAction func textFieldDidChanged(_ sender: Any) {
        let isValidForm = isValidFormInput()
        btnUpdate.isEnabled = isValidForm
    }
    
    func saveGeotification(geotification: Geotification ) {
        let item = NSKeyedArchiver.archivedData(withRootObject: geotification)
        UserDefaults.standard.set(item, forKey: PreferencesKeys.savedItem)
    }
    
    func loadGeotification() {
        let obj = UserDefaults.standard.object(forKey: PreferencesKeys.savedItem)
        
        var savedGeotification : Geotification?
        
        if (obj != nil) {
            savedGeotification = NSKeyedUnarchiver.unarchiveObject(with: obj as! Data) as? Geotification
        }
        
        if (savedGeotification == nil) {
            // set default to home
            let coordinate = CLLocationCoordinate2DMake(DEFAULT_LATITUDE, DEFAULT_LONGITUDE)
            let radius = DEFAULT_RADIUS
            let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
            let identifier = DEFAULT_IDENTIFIER
            let note = DEFAULT_NOTE
            
            savedGeotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note)
            self.stopMonitoring(geotification: savedGeotification!)
            self.startMonitoring(geotification: savedGeotification!)
            saveGeotification(geotification: savedGeotification!)
        }
        
        // update UI
        tfLatitude.text = "\(savedGeotification!.coordinate.latitude)"
        tfLongitude.text = "\(savedGeotification!.coordinate.longitude)"
        tfRadius.text = "\(savedGeotification!.radius)"
        tfNote.text = savedGeotification?.note
    }
    
    func isValidFormInput() -> Bool {
        return !(tfLatitude.text?.isEmpty)!
        && !(tfLongitude.text?.isEmpty)!
        && !(tfRadius.text?.isEmpty)!
    }
    
    func region(withGeotification geotification: Geotification) -> CLCircularRegion {
        // 1
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        
//        if (geotification.eventType == .onBoth) {
//            region.notifyOnEntry = true
//            region.notifyOnExit = true
//        } else {
//            region.notifyOnEntry = (geotification.eventType == .onEntry)
//            region.notifyOnExit = !region.notifyOnEntry
//        }
        return region
    }
    
    func startMonitoring(geotification: Geotification) {
        // 1
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert(withTitle:"Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
        }
        // 3
        let region = self.region(withGeotification: geotification)
        // 4
        locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
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


// MARK: implement delegate
extension GeotificationViewController {
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        showAlert(withTitle: "monitoringDidFailFor", message: "Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {    
        print("Location Manager failed with the following error: \(error)")
    }
    
}
