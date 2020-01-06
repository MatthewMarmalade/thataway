//
//  WaypointTableViewCell.swift
//  Compass
//
//  Created by Matthew Marsland on 8/12/19.
//  Copyright © 2019 Tectane. All rights reserved.
//

import UIKit
import CoreLocation

class WaypointTableViewCell: UITableViewCell, CLLocationManagerDelegate {

    //Properties

    let defaults:UserDefaults = UserDefaults.standard
    var waypoint: Waypoint?
    var km:Bool = true
    
    var currentLocation:CLLocation = CLLocation(latitude: 0, longitude: 0)
    var currentHeading:CLHeading?
    var currentDeg:Double?
    var locationManager:CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var nameLabel: UILabel!
    //@IBOutlet weak var latLabel: UILabel!
    //@IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var disLabel: UILabel!
    @IBOutlet weak var enabledButton: UIButton!
    @IBOutlet weak var pointerImage: UIImageView!
    
    /*
    @IBAction func switchImage(_ sender: Any) {
        if (enabledButton.isSelected) {
            pointerImage.image = UIImage(named: "listPointerEnabled")
        } else {
            pointerImage.image = UIImage(named: "listPointerDisabled")
        }
    }
 */
    func initCell(waypoint:Waypoint, km:Bool) {
        //print("creating cell... \(waypoint.name)")
        self.waypoint = waypoint
        self.km = km
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        nameLabel.text = waypoint.name
        formatAndUpdateDisLabel()
        enabledButton.isSelected = waypoint.enabled
        enabledButton.tintColor = waypoint.color
        enabledButton.alpha = 0.8
        pointerImage.tintColor = UIColor.white
//        let direction = waypoint.dirFromLocation(location: currentLocation)
//        setDirection(imageView: pointerImage, newDirection: direction - (currentDeg ?? 0.0))
    }
    
    func formatAndUpdateDisLabel() {
        let formattedString = Waypoint.formatDist(distance:waypoint?.distance)
        disLabel.text = formattedString
    }
    
    func setDirection() {
        let direction = waypoint?.dirFromLocation(location: currentLocation)
        let newDirection = (direction ?? 0.0) - (currentDeg ?? 0.0)
        let angle = CGFloat(newDirection) * CGFloat.pi / 180
        let transform = CGAffineTransform(translationX: 0.0, y: 0.0)
        pointerImage.transform = transform.rotated(by: angle)
    }
    
    //MARK: LocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("new location!")
        currentLocation = locations[locations.count - 1]
        waypoint?.distance = waypoint?.location.distance(from:currentLocation)
        formatAndUpdateDisLabel()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading:CLHeading) {
        let mag = defaults.bool(forKey: "mag")
        let newDeg = mag ? newHeading.magneticHeading : newHeading.trueHeading
        //print("NewDeg: \(newDeg)")
        currentHeading = newHeading
        currentDeg = newDeg
        setDirection()
        //self.tableView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        //contentView.backgroundColor = UIColor.blue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
