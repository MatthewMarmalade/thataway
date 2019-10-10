//
//  Waypoint.swift
//  Compass
//
//  Created by Matthew Marsland on 8/12/19.
//  Copyright © 2019 Tectane. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class Waypoint: NSObject, NSCoding{
    
    //Properties
    var location:   CLLocation
    var name:       String
    var color:      UIColor
    //var colorText:  String
    var distance:   Double?
    var enabled:    Bool
    
    static let colorDict:  [String: UIColor] = ["red":UIColor.red, "blue":UIColor.blue, "green":UIColor.green, "white":UIColor.white, "orange":UIColor.orange, "brown":UIColor.brown, "cyan":UIColor.cyan, "gray":UIColor.gray, "purple":UIColor.purple, "yellow":UIColor.yellow]
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("waypointFiles").path
    
    struct Keys {
        static let locationKey  = "locationKey"
        static let nameKey      = "nameKey"
        //static let colorTextKey = "colorTextKey"
        static let colorKey     = "colorKey"
        static let distanceKey  = "distanceKey"
        static let enabledKey   = "enabledKey"
    }
    
    convenience init(latitude: Double, longitude: Double, name:String, colorText:String = "white", color:UIColor = UIColor.white, distance:Double = 0.0, enabled:Bool = true) {
        let location   = CLLocation(latitude: latitude, longitude: longitude)
        self.init(location:location,name:name,/*colorText:colorText,*/color:color,distance:distance,enabled:enabled)
    }
    
    init(location: CLLocation, name: String, /*colorText:String = "white",*/ color:UIColor = UIColor.white, distance:Double = 0.0, enabled:Bool = true) {
        self.location = location
        self.name = name
        //self.colorText = colorText
        self.color = color
        self.distance = distance
        self.enabled = enabled
    }
    
    //encoding for data storage
    @objc func encode(with aCoder: NSCoder) {
        aCoder.encode(self.location, forKey: Keys.locationKey)
        aCoder.encode(self.name, forKey: Keys.nameKey)
        //aCoder.encode(self.colorText, forKey: Keys.colorTextKey)
        aCoder.encode(self.color, forKey: Keys.colorKey)
        aCoder.encode(self.distance, forKey: Keys.distanceKey)
        aCoder.encode(self.enabled, forKey: Keys.enabledKey)
    }
    
    //decoding from the data storage
    @objc required convenience init?(coder aDecoder: NSCoder) {
        let location    = aDecoder.decodeObject(forKey: Keys.locationKey)   as? CLLocation
        let name        = aDecoder.decodeObject(forKey: Keys.nameKey)       as? String
        //let colorText    = aDecoder.decodeObject(forKey: Keys.colorTextKey) as? String
        let color        = aDecoder.decodeObject(forKey: Keys.colorKey)     as? UIColor
        let distance     = aDecoder.decodeObject(forKey: Keys.distanceKey)  as? Double
        let enabled      = aDecoder.decodeBool(forKey: Keys.enabledKey)
        //let colorText = "white"
        //let color = UIColor.white
        self.init(location:location ?? CLLocation(latitude: 0, longitude: 0), name:name ?? "", /*colorText:colorText ?? "white",*/ color:color ?? UIColor.white, distance:distance ?? 0.0, enabled:enabled)
    }
    
    func dirFromLocation(location:CLLocation) -> Double {
        //should return the direction as a pure heading degree value, which can then be extrapolated/rotated to compensate for rotating the phone.
        //so we need the inverse... cos, say, which will tell us better information to prevent 180deg errors.
        let dx = self.location.coordinate.latitude - location.coordinate.latitude
        let dy = self.location.coordinate.longitude - location.coordinate.longitude
        let angle = atan2(dy, dx) / .pi * 180
        if angle < 0 {
            return 360 + angle
        } else {
            return angle
        }
    }
    
    func rename(newName : String) {
        self.name = newName
    }
    
    /*
    func recolor(newColor : String) {
        if let color = Waypoint.colorDict[newColor] {
            self.color = color
            self.colorText = newColor
        } else {
            print("color change failed!")
        }
    }
 */
}
