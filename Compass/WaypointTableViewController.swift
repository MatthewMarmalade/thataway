//
//  WaypointTableViewController.swift
//  Compass
//
//  Created by Matthew Marsland on 8/13/19.
//  Copyright © 2019 Tectane. All rights reserved.
//

import UIKit
import CoreLocation

class WaypointTableViewController: UITableViewController, CLLocationManagerDelegate {
    let defaults:UserDefaults = UserDefaults.standard
    var distanceUnit = true
    
    var waypoints = WaypointList()
    var currentLocation:CLLocation = CLLocation(latitude: 0, longitude: 0)
    var currentHeading:CLHeading?
    var currentDeg:Double?
    var locationManager:CLLocationManager = CLLocationManager()
    
    
    @IBAction func waypointEnablingChanged(_ sender: UIButton) {
        let waypointSwitch = sender
        waypointSwitch.isSelected = !waypointSwitch.isSelected
        waypoints[waypointSwitch.tag].enabled = waypointSwitch.isSelected
        waypoints.saveWaypoints()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if waypoints.isEmpty() {
            waypoints.loadWaypoints()
        }
        //cases 1, 2, and 3: Saving.
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        distanceUnit = defaults.bool(forKey: "km")
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        // temporarily completed implementation - do we want more than one section?
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waypoints.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "WaypointTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? WaypointTableViewCell else {
            fatalError("The dequeued cell is not an instance of WaypointTableViewCell")
        }
        
        // Configure the cell
        let waypoint = waypoints[indexPath.row]
        cell.nameLabel.text = waypoint.name
        //cell.latLabel.text = String(format: "%0.8f", waypoint.location.coordinate.latitude)
        //cell.lonLabel.text = String(format: "%0.8f", waypoint.location.coordinate.longitude)
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        var amount = (waypoint.distance ?? 0) / 1000
        var unit = "km"
        if !distanceUnit {
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
        cell.disLabel.text = "\(formattedString ?? "0.0")" + unit
        
        cell.enabledButton.isSelected = waypoint.enabled
        cell.enabledButton.tintColor = waypoint.color
        cell.enabledButton.alpha = 0.8
        cell.pointerImage.tintColor = UIColor.white
        cell.enabledButton.tag = indexPath.row
        let direction = waypoint.dirFromLocation(location: currentLocation)
        setDirection(imageView: cell.pointerImage, newDirection: direction - (currentDeg ?? 0.0))
        //cell.enabledButton.imageView

        return cell
    }
    
    // Override to support conditional editing of the table view.
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            waypoints.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            waypoints.saveWaypoints()
            //print("Deleted Waypoint")
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = waypoints[fromIndexPath.row]
        waypoints.remove(at: fromIndexPath.row)
        waypoints.insert(item: itemToMove, at: to.row)
        waypoints.saveWaypoints()
    }
 

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    //MARK: LocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[locations.count - 1]
        //print("Location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        //print(locations.count)
        for i in 0..<waypoints.count() {
            waypoints[i].distance = waypoints[i].location.distance(from:currentLocation)
        }
        self.tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading:CLHeading) {
        let newDeg = newHeading.magneticHeading
        //print("Heading: \(newDeg)")
        currentHeading = newHeading
        currentDeg = newDeg
        self.tableView.reloadData()
    }

    func setDirection(imageView: UIImageView, newDirection:Double) {
        //print("setting direction: \(currentHeading?.magneticHeading ?? 0.0)")
        let direction = CGFloat(newDirection) * CGFloat.pi / 180
        let transform = CGAffineTransform(translationX: 0.0, y: 0.0)
        imageView.transform = transform.rotated(by: direction)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        
        guard let waypointDetailViewController = segue.destination as? WaypointDetailViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        guard let selectedWaypointCell = sender as? WaypointTableViewCell else {
            fatalError("Unexpected sender: \(sender ?? "no sender")")
        }
        guard let indexPath = tableView.indexPath(for: selectedWaypointCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let selectedWaypoint = waypoints[indexPath.row]
        waypointDetailViewController.waypoint = selectedWaypoint
        waypointDetailViewController.newWaypoint = false
        
    }
    
    //returning from an edit view
    @IBAction func unwindToWaypointList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? WaypointDetailViewController, let waypoint = sourceViewController.waypoint {
            //print("you unwound to waypoint list successfully!")
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                //Updating an existing waypoint
                waypoints[selectedIndexPath.row] = waypoint
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                waypoints.saveWaypoints()
            }
        }
    }
 

}
