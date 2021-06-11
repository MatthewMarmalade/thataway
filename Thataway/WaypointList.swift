//
//  WaypointList.swift
//  Compass
//
//  Created by Matthew Marsland on 9/4/19.
//  Copyright © 2019 Matthew Marsland. All rights reserved.
//

import UIKit

class WaypointList: NSObject {
    var list = [Waypoint]()
    var enabledWaypoints = [Waypoint]()
    
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
        enabledWaypoints.removeAll()
        list.forEach{waypoint in
            if waypoint.enabled {
                enabledWaypoints.append(waypoint)
            }
        }
        //sort by distance
        enabledWaypoints.sort(by: {(w1, w2) -> Bool in
            return w1.distance ?? 0 < w2.distance ?? 0;
        })
        return enabledWaypoints
    }
    
    func minMax() -> (Double, Double, Double, Double, Double){
        var (minLat, minLon) = (0.0, 0.0)
        if !enabledWaypoints.isEmpty {
            (minLat, minLon) = (enabledWaypoints[0].location.coordinate.latitude, enabledWaypoints[0].location.coordinate.longitude)
        }
        var (maxLat, maxLon) = (minLat, minLon)
        var maxDist = 0.0
        enabledWaypoints.forEach{waypoint in
            let dist = waypoint.distance ?? 0.0
            maxDist = max(dist, maxDist)
            let lat = waypoint.location.coordinate.latitude
            let lon = waypoint.location.coordinate.longitude
            minLat = min(lat, minLat)
            minLon = min(lon, minLon)
            maxLat = max(lat, maxLat)
            maxLon = max(lon, maxLon)
        }
        return (minLat, minLon, maxLat, maxLon, maxDist)
    }
    
    func count() -> Int {
        return list.count
    }
    
    func enabledCount() -> Int {
        return enabledWaypoints.count
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
