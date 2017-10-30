//
//  ViewController.swift
//  BLEDemo
//
//  Created by John Cottrell on 9/2/17.
//  Copyright © 2017 John Cottrell. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    let locationManager = CLLocationManager()
    let beaconRegionMbedUUID = "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"       // Custom (mbed)
    let beaconRegionEstimoteUUID = "B9407F30-F5F8-466E-AFF9-25556B57FE6D"   // Estimote
    let beaconRegionNordicUUID =   "01122334-4556-6778-899A-ABBCCDDEEFF0"   // Nordic
    let toIgnore = "3CC695E7-CB6E-4EBC-BBB3-B5CFACA26544"                   // iMac
    let useMbed = true
    let useEstimote = false
    let useNordic = false
    var uuids: [String] = []
    var beaconInfoArray: [BeaconInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "BLE Demo"
        
        manager = CBCentralManager(delegate: self, queue: nil)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        if useMbed == true {
            let uuidMbed = UUID(uuidString: beaconRegionMbedUUID)!
            let beaconRegionMbed: CLBeaconRegion = CLBeaconRegion(proximityUUID: uuidMbed, identifier: "mbed")
            locationManager.startRangingBeacons(in: beaconRegionMbed)
            locationManager.startMonitoring(for: beaconRegionMbed)
        }
        
        if useNordic == true {
            let uuidNordic = UUID(uuidString: beaconRegionNordicUUID)!
            let beaconRegionNordic: CLBeaconRegion = CLBeaconRegion(proximityUUID: uuidNordic, identifier: "nordic")
            locationManager.startRangingBeacons(in: beaconRegionNordic)
            locationManager.startMonitoring(for: beaconRegionNordic)
        }
        
        if useEstimote == true {
            let uuidEstimote = UUID(uuidString: beaconRegionEstimoteUUID)!
            let beaconRegionEstimote: CLBeaconRegion = CLBeaconRegion(proximityUUID: uuidEstimote, identifier: "estimote")
            locationManager.startRangingBeacons(in: beaconRegionEstimote)
            locationManager.startMonitoring(for: beaconRegionEstimote)
        }

        // Request auth for user notifs
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {(granted, error) in })
        
        // Set tableView dataSource and delegates to view controller (i.e. self)
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // The non-iBeacons are detected using Apple's CoreBluetooth library (foreground detection only)
    // MARK: - Central Delegate Methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("centralManagerDidUpdateState state:\(central.state)")
        manager.scanForPeripherals(withServices: nil, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        let uuidIMac = UUID(uuidString: toIgnore);
        
        if peripheral.identifier != uuidIMac {
            if let uuid = advertisementData["kCBAdvDataManufacturerData"] {

                print("--------------")
                print("PERIPH: \(peripheral)")
                print("ADV DATA: \(advertisementData)")
                print("RSSI: \(RSSI)")
                print("UUID: \(uuid)")
                print("UUID Type: \(type(of: uuid))");
                if let advData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
                    print("Convert")
                } else {
                    print("Can't convert")
                }
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    private func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
    }
    
    // iBeacons can be detected in the foreground and background using the CoreLocation framework
    //MARK: - CLocationManager Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion)
    {
        if state == .inside {
            print("locationManager didDetermineState INSIDE")
        }
        
        if state == .outside {
            print("locationManager didDetermineState OUTSIDE")
        }
        
        if state == .unknown {
            print("locationManager didDetermineState UNKNOWN")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {

        print("beacons: \(beacons)")
        
        for beacon in beacons {
            let major = beacon.major
            let minor = beacon.minor
            
            print("Result: \(beacon.proximityUUID) :: \(major)-\(minor)")
            
            let strUUID = beacon.proximityUUID.uuidString
            
            if uuids.contains(strUUID) == false {
                uuids.append(strUUID)
                tableView.reloadData()
            }
            
            let found = beaconInfoArray.filter{$0.uuid == strUUID}.count > 0
            var identifier: String = ""
            if found == false {
                if strUUID == "E20A39F4-73F5-4BC4-A12F-17D1AD07A961" {
                    identifier = "mbed"
                }
                
                let beaconInfo = BeaconInfo(uuid: strUUID, identifier: identifier, inRange: true)
                beaconInfoArray.append(beaconInfo)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        let myRegion = region as! CLBeaconRegion
        print("uuid = \(myRegion.proximityUUID) \(String(describing: myRegion.major))::\(String(describing: myRegion.minor))")
        print("ENTER REGION \(region.identifier) ON \(Date())")
        
        for i in 0 ... beaconInfoArray.count - 1 {
            if beaconInfoArray[i].identifier == region.identifier {
                beaconInfoArray[i].inRange = true;
                tableView.reloadData()
            }
        }
        notification(type: "enter")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        print("EXIT REGION \(region.identifier) ON \(Date())")
       
        for i in 0 ... beaconInfoArray.count - 1 {
            if beaconInfoArray[i].identifier == region.identifier {
                beaconInfoArray[i].inRange = false;
                tableView.reloadData()
            }
        }
        notification(type: "exit")
    }
    
    // User Notification
    func notification(type: String) {
        
        // Notification: Content
        let content = UNMutableNotificationContent()
        content.title = "Region Change"
        content.subtitle = "Region change notification"
        content.body = "Region change \(type)"
        content.categoryIdentifier = "message"
        
        // Notification: Trigger
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1.0,
            repeats: false)
        
        // Notification: Request
        let request = UNNotificationRequest(
            identifier: "com.jfc.message",
            content: content,
            trigger: trigger
        )
        
        // Notification: Add
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uuids.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        
        //let strUUID = uuids[indexPath.row]
        let beaconInfo = beaconInfoArray[indexPath.row]
        let strUUID = beaconInfo.uuid
        
        var cellText: String
        
        if strUUID == beaconRegionEstimoteUUID {
            cellText = "Estimote"
        } else if strUUID == beaconRegionMbedUUID {
            cellText = "Mbed"
        } else if strUUID == beaconRegionNordicUUID {
            cellText = "Nordic"
        } else {
            cellText = "unknown"
        }
        
        if beaconInfo.inRange == true {
            (cell.contentView.viewWithTag(100) as! UIImageView).image = UIImage(named: "dot_green.png")
        } else {
            (cell.contentView.viewWithTag(100) as! UIImageView).image = UIImage(named: "dot_red.png")
        }
        (cell.contentView.viewWithTag(200) as! UILabel).text = cellText

        return cell
    }
}
