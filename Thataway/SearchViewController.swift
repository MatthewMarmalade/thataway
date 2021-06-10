//
//  SearchViewController.swift
//  Thataway
//
//  Created by Matthew Marsland on 6/10/21.
//  Copyright © 2021 Tectane. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class SearchViewController: UIViewController {
    
    var searchController : UISearchController?
    
    //var waypoint : Waypoint!
    var latField : UITextField? = nil
    var lonField : UITextField? = nil
    
    var originalPlacemark : MKPlacemark? = nil
    var selectedPlacemark : MKPlacemark? = nil
    
    
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var dropPinButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //resetButton.isEnabled = false
        saveButton.isEnabled = false
        
        let searchTable = storyboard!.instantiateViewController(identifier: "SearchTable") as! SearchTableViewController //storyboard!.instantiateViewController(withIdentifier: "SearchTable") as! SearchTableViewController
        searchController = UISearchController(searchResultsController: searchTable)
        searchController?.searchResultsUpdater = searchTable
        
        let latitude = Double(latField!.text!) ?? 0.0
        let longitude = Double(lonField!.text!) ?? 0.0
        originalPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: originalPlacemark!.coordinate, span: span)
        
        searchTable.region = region
        searchTable.handleMapSearchDelegate = self
        
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = originalPlacemark!.coordinate
        mapView.addAnnotation(annotation)
        
        let newSearchBar = searchController!.searchBar
        newSearchBar.sizeToFit()
        newSearchBar.placeholder = "Search for places"
        //searchBar = newSearchBar
        navigationItem.titleView = searchController?.searchBar
        //toolbarSearch = searchController?.searchBar
        
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    @IBAction func resetButton(_ sender: Any) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        let region = MKCoordinateRegion(center: originalPlacemark?.coordinate ?? CLLocationCoordinate2DMake(0.0, 0.0), span: span)
        
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = originalPlacemark!.coordinate
        
        mapView.addAnnotation(annotation)
        
        selectedPlacemark = originalPlacemark
        
        //resetButton.isEnabled = false
        resetButton.isEnabled = false
    }
    
    @IBAction func dropPinButton(_ sender: Any) {
        selectedPlacemark = MKPlacemark(coordinate: mapView.region.center)
        
        //remove old waypoints
        mapView.removeAnnotations(mapView.annotations)
        
        let oldAnnotation = MKPointAnnotation()
        oldAnnotation.coordinate = originalPlacemark!.coordinate
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = selectedPlacemark!.coordinate
        
        mapView.addAnnotation(oldAnnotation)
        mapView.addAnnotation(newAnnotation)
        
        //let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        //let region = MKCoordinateRegion(center: selectedPlacemark!.coordinate, span: span)
        //mapView.setRegion(region, animated: true)
        
        //resetButton.isEnabled = true
        saveButton.isEnabled = true
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if let location = selectedPlacemark?.location {
            //waypoint.location = location
            latField?.text = String(location.coordinate.latitude)
            lonField?.text = String(location.coordinate.longitude)
            print("SEARCH SAVED")
        } else {
            print("SEARCH SAVE BUTTON FAILED")
        }
        
        navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewController : HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        selectedPlacemark = placemark
        
        //remove old waypoint
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        //resetButton.isEnabled = true
        resetButton.isEnabled = false
    }
}
