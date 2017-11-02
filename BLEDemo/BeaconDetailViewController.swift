//
//  BeaconDetailViewController.swift
//  BLEDemo
//
//  Created by John Cottrell on 11/1/17.
//  Copyright © 2017 John Cottrell. All rights reserved.
//

import Foundation
import UIKit

class BeaconDetailViewController: UIViewController {
    
    var beaconInfo: BeaconInfo!
    
    @IBOutlet weak var beaconImage: UIImageView!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var inRangeLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    @IBOutlet weak var proximityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for notification updates
        NotificationCenter.default.addObserver(self, selector: #selector(bleUpdateReceived), name: Notification.Name("BLE_UPDATE"), object: nil)
        self.title = "Details"
        updateUI()
    }
    
    func bleUpdateReceived(_ notification: Notification) {
        
        beaconInfo = notification.userInfo!["userInfo"] as! BeaconInfo
        updateUI()
    }
    
    func updateUI() {
        
        if let beaconInfo = beaconInfo {
            uuidLabel.text = beaconInfo.uuid
            identifierLabel.text = beaconInfo.identifier
            if beaconInfo.inRange == true {
                inRangeLabel.text = "Yes"
            } else {
                inRangeLabel.text = "No"
            }
            majorLabel.text = String(beaconInfo.major)
            minorLabel.text = String(beaconInfo.minor)
        
            beaconImage.image = UIImage(named: beaconInfo.beaconImage)
            
            switch beaconInfo.proximity {
                case 0: proximityLabel.text = "Unknown"
                case 1: proximityLabel.text = "Immediate"
                case 2: proximityLabel.text = "Near"
                case 3: proximityLabel.text = "Far"
                default: proximityLabel.text = "n/a"
            }
        }
    }
}
