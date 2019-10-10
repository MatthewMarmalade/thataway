//
//  WaypointList.swift
//  Compass
//
//  Created by Matthew Marsland on 9/4/19.
//  Copyright © 2019 Tectane. All rights reserved.
//

import UIKit

class WaypointList: NSObject {
    var list = [Waypoint]()
    
    func append(waypoint:Waypoint) {
        list.append(waypoint)
    }
    
    func remove(at: Int) {
        list.remove(at: at)
    }
    
    func insert(item: Waypoint, at: Int) {
        list.insert(item, at: at)
    }
    
    func isEmpty() -> Bool {
        return list.isEmpty
    }
    
    func loadWaypoints() {
        //print("Loading")
        list = (NSKeyedUnarchiver.unarchiveObject(withFile: Waypoint.ArchiveURL) as? [Waypoint]) ?? [Waypoint(latitude: 0.0, longitude: 0.0, name: "Null Island")]
    }
    
    func saveWaypoints() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(list, toFile: Waypoint.ArchiveURL)
        if !isSuccessfulSave {
            print("Failed to save waypoints!")
        } else {
            //print("Saved!")
        }
    }
    
    func enabledList() -> [Waypoint] {
        var enabledWaypoints = [Waypoint]()
        list.forEach{waypoint in
            if waypoint.enabled {
                enabledWaypoints.append(waypoint)
            }
        }
        return enabledWaypoints
    }
    
    func count() -> Int {
        return list.count
    }
    
    subscript(index:Int) -> Waypoint {
        get {
            return list[index]
        }
        set(newValue) {
            list[index] = newValue
        }
    }

}
