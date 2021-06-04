//
//  Waypoint.swift
//  Compass
//
//  Created by Matthew Marsland on 8/12/19.
//  Copyright © 2019 Matthew Marsland. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

class Waypoint: NSObject, NSCoding, MKAnnotation{
    
    
    //Properties
    static let defaults:   UserDefaults = UserDefaults.standard
    var location:   CLLocation
    var coordinate: CLLocationCoordinate2D
    var name:       String
    var color:      UIColor
    var distance:   Double?
    var enabled:    Bool
    
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
        self.coordinate = location.coordinate
        self.name = name
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
        let aLat = location.coordinate.latitude / 180 * .pi
        let bLat = self.location.coordinate.latitude / 180 * .pi
        let aLon = location.coordinate.longitude / 180 * .pi
        let bLon = self.location.coordinate.longitude / 180 * .pi
        
        let (x, y) = Waypoint.getXY(aLat:aLat,aLon:aLon,bLat:bLat,bLon:bLon)
        let angle = atan2(x, y) / .pi * 180
        //let angle = atan2(dy, dx) / .pi * 180
        if angle < 0 {
            return 360 + angle
        } else {
            return angle
        }
    }
    
    static func getXY(aLat:Double, aLon:Double, bLat:Double, bLon:Double) -> (Double, Double) {
        let dLon = bLon - aLon
        let x = cos(bLat) * sin(dLon)
        let y = (cos(aLat) * sin(bLat)) - (sin(aLat) * cos(bLat) * cos(dLon))
        return (x, y)
    }
    
    static func formatDist(distance:Double?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        var amount = (distance ?? 0) / 1000
        
        let km = defaults.bool(forKey: "km")
        var unit = "km"
        if !km {
            amount = amount * 0.6213712
            unit = "mi"
        }
        
        if amount < 1 {
            amount = floor(amount * 1000) / 1000
        } else if amount < 10 {
            amount = floor(amount * 100) / 100
        } else if amount < 100 {
            amount = floor(amount * 10) / 10
        } else {
            amount = floor(amount)
        }
        let formattedString = formatter.string(for: amount)
        return "\(formattedString ?? "0.0") " + unit
    }
    
    func rename(newName : String) {
        self.name = newName
    }
    
    var subtitle: String? {
        return Waypoint.formatDist(distance:distance)
    }
    
    var title: String? {
        return name
    }
    
}
