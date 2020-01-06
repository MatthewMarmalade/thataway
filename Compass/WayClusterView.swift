//
//  UserAnnotation.swift
//  Compass
//
//  Created by Matthew Marsland on 1/4/20.
//  Copyright © 2020 Tectane. All rights reserved.
//

import UIKit
import MapKit

class WayClusterView: MKMarkerAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if let cluster = annotation as? MKClusterAnnotation {
            //let waypointsInCluster = cluster.memberAnnotations.count
            //print("I've been prepared for display")
            //print(cluster.memberAnnotations.count)
            //print(cluster.memberAnnotations[0].title)
            cluster.title = formatClusterTitle(cluster: cluster)
            cluster.subtitle = formatClusterSubtitle(cluster: cluster)
        }
    }
    
    func formatClusterTitle(cluster:MKClusterAnnotation) -> String {
        let members = cluster.memberAnnotations
        var title = "\n"
        for i in 0..<members.count-1 {
            title = title + members[i].title!! + ",\n"
        }
        title = title + members[members.count-1].title!!
        return title
    }
    
    func formatClusterSubtitle(cluster:MKClusterAnnotation) -> String? {
        let members = cluster.memberAnnotations
        if let waypoints = members as? [Waypoint] {
            var minDist = waypoints[0].distance!
            var maxDist = 0.0
            for i in 0..<waypoints.count {
                minDist = min(minDist, waypoints[i].distance!)
                maxDist = max(maxDist, waypoints[i].distance!)
            }
            //let avg = sum / Double(waypoints.count)
            return "[" + Waypoint.formatDist(distance: minDist) + " - " + Waypoint.formatDist(distance: maxDist) + "]"
        }
        return nil
    }
}
