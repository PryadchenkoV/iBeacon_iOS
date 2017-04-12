//
//  BeaconInfo.swift
//  iBeacon_iOS
//
//  Created by Ivan Pryadchenko on 10.02.17.
//  Copyright © 2017 Ivan Pryadchenko. All rights reserved.
//

import UIKit

class BeaconInfo: NSObject,NSCoding {

    var minor = 0
    var major = 0
    var coordX = 0
    var coordY = 0
    var floor = ""
    var name = ""
    
    init(minor:Int, major:Int, coordX:Int, coordY:Int, floor:String, name: String) {
        self.minor = minor
        self.major = major
        self.coordX = coordX
        self.coordY = coordY
        self.floor = floor
        self.name = name
    }
    
    override init() {
    }
    
    func setMajorAndMinor(minor:Int, major:Int) {
        self.minor = minor
        self.major = major
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let minor = aDecoder.decodeInteger(forKey: "minor")
        let major = aDecoder.decodeInteger(forKey: "major")
        let coordX = aDecoder.decodeInteger(forKey: "coordX")
        let coordY = aDecoder.decodeInteger(forKey: "coordY")
        let floor = aDecoder.decodeObject(forKey: "floor") as! String
        let name = aDecoder.decodeObject(forKey: "name") as! String
        
        self.init(minor: minor, major: major, coordX: coordX, coordY: coordY, floor: floor, name: name)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(minor, forKey: "minor")
        aCoder.encode(major, forKey: "major")
        aCoder.encode(coordX, forKey: "coordX")
        aCoder.encode(coordY, forKey: "coordY")
        aCoder.encode(floor, forKey: "floor")
        aCoder.encode(name, forKey: "name")
    }
    
}
