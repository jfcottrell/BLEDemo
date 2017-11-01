//
//  BeaconInfo.swift
//  BLEDemo
//
//  Created by John Cottrell on 10/30/17.
//  Copyright © 2017 John Cottrell. All rights reserved.
//

import Foundation
import CoreLocation

struct BeaconInfo {
    var uuid: String
    var identifier: String
    var inRange: Bool
    var major: Int
    var minor: Int
    var rssi: Int
    var proximity: Int
}
