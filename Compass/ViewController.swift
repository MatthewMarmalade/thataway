//
//  ViewController.swift
//  Compass
//
//  Created by Matthew Marsland on 8/3/19.
//  Copyright © 2019 Tectane. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation



class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var latitudeVar: UILabel!
    @IBOutlet weak var longitudeVar: UILabel!
    @IBOutlet weak var headingVar: UILabel!
    @IBOutlet weak var letterVar: UILabel!
    @IBOutlet weak var needle: UIImageView!
    @IBOutlet weak var displayType: UISegmentedControl!
    
    let defaults:UserDefaults = UserDefaults.standard
    
    var currentLocation:CLLocation = CLLocation(latitude: 0, longitude: 0)
    var currentHeading:CLHeading?
    var currentDeg:Double?
    
    var needleDirection = 0
    var locationManager:CLLocationManager = CLLocationManager()
    //we need a list of stored locations, with some data about them - sounds like we should make a class.
    var waypoints = WaypointList()
    var enabledWaypoints = [Waypoint]()
    var tempPoint : Waypoint?
    var waypointers = [UIImageView]()
    var waymarkers = [UIImageView]()
    
    var (minLat, minLon, maxLat, maxLon) = (0.0, 0.0, 1.0, 1.0)
    var sum = 1.0
    var maxDist = 1.0
    var normalization = 1.0
    var locationPointer : UIImageView?
    var centreOffset = 30.0
    var relativeDistance = 100.0
    
    //MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //This gets called every time the view will appear, even if it's already in memory. Lets us update the data models, because they can change dynamically and shouldn't wait for a viewDidLoad().
        //case 1: We just unwound from the table view, after making some modifications. Our data has been updated, but we need to update the displays and basically run startup code again.
        
        //case 2: We just opened the app, with all local data cleared, and need to reload. We'll know this because the list should be empty.
        
        //case 3: We have just opened the app for the first time, with no local data saved. In this case we know from case 2 that there's something missing.
        
        //case 2 or 3:
        if waypoints.isEmpty() {
            waypoints.loadWaypoints()
        }
        //cases 1, 2, and 3: Creating pointer displays and saving.
        
        waypointers.forEach{$0.removeFromSuperview()} //what does this do...
        waypointers.removeAll() //there's got to be a more efficient way to do this.
        waymarkers.forEach{$0.removeFromSuperview()}
        waymarkers.removeAll()
        
        enabledWaypoints = waypoints.enabledList()
        //print("Enabled Waypoints: \(enabledWaypoints.count)")
        (minLat, minLon, maxLat, maxLon, maxDist) = waypoints.minMax()
        normalization = max(maxLat - minLat, maxLon - minLon) + 1
        for i in 0..<enabledWaypoints.count {
            let waypointI = enabledWaypoints[i]
            let newWayPointer = newPointer(height: 40.0, color: waypointI.color)
            positionInView(waypointer: newWayPointer, waypoint: waypointI)
            
            let newWayMarker = newMarker(color: waypointI.color)
            positionInView(waymarker: newWayMarker, waypoint: waypointI)
            
            if displayType.selectedSegmentIndex == 0 {
                newWayPointer.isHidden = false
                newWayMarker.isHidden = true
            } else {
                newWayPointer.isHidden = true
                newWayMarker.isHidden = false
            }
            
            waypointers.append(newWayPointer)
            waymarkers.append(newWayMarker)
        }
        
        locationPointer?.removeFromSuperview()
        locationPointer = newUserPointer()
        setDirectionAndLocationInMap(imageView: locationPointer!, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, newDirection: 0.0)
        
        if displayType.selectedSegmentIndex == 0 {
            needle.tintColor = UIColor.white
            locationPointer?.isHidden = true
        } else {
            needle.tintColor = UIColor.black
            locationPointer?.isHidden = false
        }

        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    //MARK: ViewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //saveWaypoints()
    }
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "Charter", size: 20.0)!]
        displayType.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Charter", size: 12.0)!, NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        //displayType.setTitleTextAttributes([], for: .normal)
        //segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        //segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        let hasLaunchedKey = "HasLaunched"
        let hasLaunched = defaults.bool(forKey: hasLaunchedKey)
        if !hasLaunched {
            defaults.set(isMetric(), forKey: "km")
            defaults.set(true, forKey: "mag")
            defaults.set(true, forKey: hasLaunchedKey)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
        //App seems to not function correctly re:rotation when oriented in landscape.
    }
    
    //MARK: LocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[locations.count - 1]
        //print(locations.count)
        latitudeVar.text = String(format: "%.4f", currentLocation.coordinate.latitude)
        longitudeVar.text = String(format: "%.4f", currentLocation.coordinate.longitude)
        for i in 0..<waypoints.count() {
            waypoints[i].distance = waypoints[i].location.distance(from:currentLocation)
        }
        for i in 0..<enabledWaypoints.count {
            positionInView(waymarker: waymarkers[i], waypoint: enabledWaypoints[i])
//
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading:CLHeading) {
        let mag = defaults.bool(forKey: "mag")
        let newDeg = mag ? newHeading.magneticHeading : newHeading.trueHeading
        //print("NewDeg: \(newDeg)")
        //let newDeg = newHeading.magneticHeading
        headingVar.text = String(format: "%.1f", newDeg) + "˚"// + " err " + String(format: "%.4f", newHeading.headingAccuracy)
        letterVar.text = calculateLetterHeading(degrees: newDeg)
        for i in 0..<enabledWaypoints.count {
            let waypointI = enabledWaypoints[i]
            positionInView(waypointer: waypointers[i], waypoint: waypointI)
        }
        setDirectionAndLocationInMap(imageView: locationPointer!, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, newDirection: newDeg)
        currentHeading = newHeading
        currentDeg = newDeg
    }
    
    //MARK: - PositionInView
    func positionInView(waypointer: UIImageView, waypoint: Waypoint) {
        let direction = waypoint.dirFromLocation(location: currentLocation)
        let relativeWeight = calculateRelativeWeight(absDistance: waypoint.distance ?? 0.0)
        let newDirection = direction - (currentDeg ?? 0.0)
        setDirectionAndLocationInCompass(imageView: waypointer, newDirection: newDirection, newRadius: centreOffset + (relativeWeight * relativeDistance))
    }
    
    func positionInView(waymarker: UIImageView, waypoint: Waypoint) {
        setLocationInMap(imageView: waymarker, latitude: waypoint.location.coordinate.latitude, longitude: waypoint.location.coordinate.longitude)
    }
    
    private func calculateRelativeWeight(absDistance:Double) -> Double {
        let weight = (absDistance) / maxDist
        //return pow(normalizedDistance, 0.3)
        //let logDistance = log2(normalizedDistance + 1)
        return sqrt(weight)
    }
    
    //MARK: SetDirectionAndLocation
    func setDirectionAndLocationInCompass(imageView: UIImageView, newDirection:Double, newRadius:Double) {
        let direction = CGFloat(newDirection) * CGFloat.pi / 180
        let x = CGFloat(newRadius) * sin(direction)
        let y = -CGFloat(newRadius) * cos(direction)
        let translationTransform = CGAffineTransform(translationX: x, y: y)
        imageView.transform = translationTransform.rotated(by: direction)
    }
    
    func setLocationInMap(imageView: UIImageView, latitude:Double, longitude:Double) {
        //we have a latitude and a longitude... and we know what the min and max are going to be bounded by. Since we have min and max as boundaries, we average them to get the centre. Subtracting the locations from the centre gets the latitude and longitude offset from the centre. These are normalized, divided by the width/height to develop the ratio. We then define an offset from the centre of the needle.
        let (cgX, cgY) = getScaledCGXY(latitude: latitude, longitude: longitude)
        imageView.transform = CGAffineTransform(translationX: cgX, y: cgY)
    }
    
    func setDirectionAndLocationInMap(imageView: UIImageView, latitude:Double, longitude:Double, newDirection:Double) {
        
        let (cgX, cgY) = getScaledCGXY(latitude: latitude, longitude: longitude)
        let rotationTransform = CGAffineTransform(rotationAngle: CGFloat(newDirection) * CGFloat.pi / 180)
        let translationTransform = CGAffineTransform(translationX: cgX, y: cgY)
        imageView.transform = rotationTransform.concatenating(translationTransform)
    }
    
    func getScaledCGXY(latitude:Double, longitude:Double) -> (CGFloat,CGFloat) {
        
//        let (centreLat, centreLon) = (((maxLat + minLat) / 2), ((maxLon + minLon) / 2))
//        let (minX, minY) = Waypoint.getXY(aLat: centreLat, aLon: centreLon, bLat: minLat, bLon: minLon)
//        let (maxX, maxY) = Waypoint.getXY(aLat: centreLat, aLon: centreLon, bLat: maxLat, bLon: maxLon)
//        let (x, y) = Waypoint.getXY(aLat: centreLat, aLon: centreLon, bLat: latitude, bLon: longitude)
        
        let (minY, minX) = rubberSheet(lat: minLat, lon: minLon)
        let (maxY, maxX) = rubberSheet(lat: maxLat, lon: maxLon)
        let (y, x) = rubberSheet(lat: latitude, lon: longitude)
        
        let (centreY, centreX) = (((maxY + minY) / 2), ((maxX + minX) / 2))
        
        var align = max(maxX-minX, maxY-minY)
        //var align = max(maxLat-minLat, maxLon-minLon)
        //print("Align: \(align)")
        if (align == 0) {
            align = 0.00000001
        }
        
        print("XY: \(x),\(y)")
        let dX = x - centreX
        let dY = y - centreY
        print("DXY: \(dX), \(dY),    CentreXY: \(centreX),\(centreY)")
        let nX = dX / align
        let nY = dY / align
        print("NXY: \(nX), \(nY),    Align: \(align)")
//        let nX = dX
//        let nY = dY
        let cgX = (CGFloat(nX) * needle.frame.width * 3/4)
        let cgY = -(CGFloat(nY) * needle.frame.height * 3/4)
        print("Needle Frame: \(needle.frame.width),\(needle.frame.height); CGXY: \(cgX),\(cgY)")
        return (cgX, cgY)
    }
    
    func rubberSheet(lat:Double, lon:Double) -> (Double, Double) {
//        let y = cos(lat / 180 * .pi) * sin(lon / 180 * .pi)
//        let x = cos(lat / 180 * .pi) * cos(lon / 180 * .pi)
        let x = lon * 60 * 1852 * cos(lat / 180 * .pi)
        let y = lat * 60 * 1852
        return (y, x)
    }
    
    //MARK: - IsMetric
    func isMetric() -> Bool {
        return ((Locale.current as NSLocale).object(forKey: NSLocale.Key.usesMetricSystem) as? Bool) ?? true
    }
    
    //MARK: NewPointer
    func newPointer(height:CGFloat, color: UIColor) -> UIImageView {
        //creates a new pointer, places it within the frame, and returns the UIImageView object.
        let imageName = "pointer.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        imageView.tintColor = color
        //imageView.alpha = 0.8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        
        imageView.widthAnchor.constraint(equalToConstant: 50 + (height / 8)).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: needle.centerYAnchor).isActive = true
        return imageView
    }
    
    func newUserPointer() -> UIImageView {
        let imageName = "userPointer.png"
        let image = UIImage(named:imageName)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: 33).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        imageView.centerXAnchor.constraint(equalTo: needle.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: needle.centerYAnchor).isActive = true
        return imageView
    }
    
    func newMarker(color:UIColor) -> UIImageView {
        //creates a new marker, places it within the frame, and returns the UIImageView object.
        let imageName = "marker.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        imageView.tintColor = color
        //imageView.alpha = 0.8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        //let x = (CGFloat(dX) * needle.frame.width)
        //let y = -(CGFloat(dY) * needle.frame.height)
        
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: needle.centerYAnchor).isActive = true

        return imageView
    }
    
    //MARK: CalculateLetterHeading
    private func calculateLetterHeading(degrees:CLLocationDegrees) -> String {
        var letter = ""
        if degrees > 337 || degrees <= 23 {
            letter = "N"
        } else if degrees > 23 && degrees <= 67 {
            letter = "NE"
        } else if degrees > 67 && degrees <= 113 {
            letter = "E"
        } else if degrees > 113 && degrees <= 157 {
            letter = "SE"
        } else if degrees > 157 && degrees <= 203 {
            letter = "S"
        } else if degrees > 203 && degrees <= 247 {
            letter = "SW"
        } else if degrees > 247 && degrees <= 293 {
            letter = "W"
        } else if degrees > 293 && degrees <= 337 {
            letter = "NW"
        } else {
            letter = "Unknown"
        }
        return letter
    }

    
    //MARK: NewWaypoint
    @IBAction func newWaypoint(_ sender: Any) {
        let newWaypoint = Waypoint(location:currentLocation,name:"New Waypoint")
        tempPoint = newWaypoint
    }
    
    //MARK: SwitchDisplayType
    @IBAction func switchDisplayType(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            //Compass, all is normal
            //make sure no compass pieces are hidden
            //etc.
            needle.tintColor = UIColor.white
            locationPointer?.isHidden = true
            for i in 0..<waypointers.count {
                waypointers[i].isHidden = false
                waymarkers[i].isHidden = true
            }
        } else if sender.selectedSegmentIndex == 1 {
            //Map, now here's a tricky bit.
            //Hide everything from the compass
            //Unhide everything from the map.
            //print("showing map")
            needle.tintColor = UIColor.black
            locationPointer?.isHidden = false
            for i in 0..<waymarkers.count {
                waymarkers[i].isHidden = false
                waypointers[i].isHidden = true
            }
        }
    }
    
    //MARK: Navigation
    //Heading into table view or detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the waypoints object to the new view controller.
        super.prepare(for: segue, sender: sender)
        if let waypointTableViewController = segue.destination as? WaypointTableViewController {
            waypointTableViewController.waypoints = waypoints
            waypointTableViewController.currentHeading = currentHeading
            waypointTableViewController.currentDeg = currentHeading?.magneticHeading
            waypointTableViewController.currentLocation = currentLocation
            //waypointTableViewController.locationManager = locationManager
            //print("Waypoints passed to TableView.")
        } else if let settingsViewController = segue.destination as? SettingsViewController {
            //print("Moving to settings.")
        } else if let editViewController = segue.destination as? WaypointDetailViewController {
            editViewController.newWaypoint = true
            editViewController.waypoint = tempPoint!
        } else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
    }
    
    //returning from table view
    @IBAction func unwindToCompass(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? WaypointDetailViewController {
            if let newWaypoint = sourceViewController.waypoint {
                //waypoints[waypoints.count() - 1] = newWaypoint
                //let index = waypoints.count() - 1
                if (sourceViewController.cancel) {
                    //waypoints.remove(at: index)
                    //waypointers[index].removeFromSuperview()
                    //waypointers.remove(at: index)
                    //waymarkers[index].removeFromSuperview()
                    //waymarkers.remove(at: index)
                } else {
                    waypoints.append(waypoint:newWaypoint)
                    waypoints.saveWaypoints() //overwrites existing save data with the new waypoint attached.
                    enabledWaypoints = waypoints.enabledList()
                    let newWayPointer = newPointer(height: 40.0, color: newWaypoint.color)
                    setDirectionAndLocationInCompass(imageView: newWayPointer, newDirection:0.0, newRadius: 30.0)
                    waypointers.append(newWayPointer)
                    let newWayMarker = newMarker(color: newWaypoint.color)
                    waymarkers.append(newWayMarker)
                    
                    if displayType.selectedSegmentIndex == 0 {
                        newWayPointer.isHidden = !newWaypoint.enabled
                        newWayMarker.isHidden = true
                    } else {
                        newWayPointer.isHidden = true
                        newWayMarker.isHidden = !newWaypoint.enabled
                    }
                }
            }
            //waypoints = sourceViewController.waypoints
            //print("you unwound to compass successfully!")
        }
    }
    
}
