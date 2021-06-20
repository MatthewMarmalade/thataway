//
//  WaypointDetailViewController.swift
//  Compass
//
//  Created by Matthew Marsland on 8/13/19.
//  Copyright © 2019 Matthew Marsland. All rights reserved.
//

import UIKit
import MapKit
import CoreGraphics

class WaypointDetailViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    

    var viewController : ViewController?
    
    
    var waypoint : Waypoint?
    var color : UIColor?
    var newWaypoint : Bool?
    
    var latitude : Double?
    var longitude : Double?
    
    //var colorText : String?

    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    //@IBOutlet weak var colorField: UITextField!
    //@IBOutlet weak var colorPicker: UIPickerView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var saveButton_2: UIButton!
    @IBOutlet weak var cancelButton_2: UIButton!
    //@IBOutlet weak var newLabel: UILabel!
    
    
    var cancel : Bool = false
    var colors : [UIColor] = ColorList.defaultColors
    //var colorTexts = ["red", "blue", "green", "white", "orange", "brown", "cyan", "gray", "purple", "yellow"]
    
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        //latField.delegate = self
        //lonField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        if let waypoint = waypoint {
            nameField.text = waypoint.name
            //latField.text = String(format:"%0.8f", waypoint.location.coordinate.latitude)
            //lonField.text = String(format:"%0.8f", waypoint.location.coordinate.longitude)
            latitude = waypoint.location.coordinate.latitude
            longitude = waypoint.location.coordinate.longitude
            color = waypoint.color 
            //colorText = waypoint.colorText
            //colorField.text = waypoint.colorText
        }
        
        if let buttonsHidden = newWaypoint {
            cancelButton_2.isHidden = !buttonsHidden
            saveButton_2.isHidden = !buttonsHidden
            cancelButton.isHidden = buttonsHidden
            saveButton.isHidden = buttonsHidden
            //newLabel.isHidden = !buttonsHidden
        }
        loadColors()
        //collectionView.allowsSelection = false
        //collectionView.backgroundColor = UIColor.black
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let latitude = latitude, let longitude = longitude {
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            
            mapView.setRegion(region, animated: false)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.subtitle = "\(String(format:"%0.4f", latitude)), \(String(format:"%0.4f", longitude))"
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
        }
        
    }
    

    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row < colors.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! ColorCollectionViewCell
            //print("IndexPath Row: \(indexPath.row)")
            let cellColor = colors[indexPath.row]
            cell.displayContent(color: cellColor)
            cell.colorButton.tag = indexPath.row
            if cellColor == color {
                print("Color \(color.debugDescription) is equal to \(cellColor.debugDescription)")
                print(indexPath)
                cell.colorButton.imageView?.image = UIImage(named: "colorCellCheck")
            } else {
                //print("Color \(color.debugDescription) is NOT equal to \(cellColor.debugDescription)")
                cell.colorButton.imageView?.image = UIImage(named: "colorCell")
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newColorCollectionViewCell", for: indexPath) as! NewColorCollectionViewCell
            cell.newColorButton.tag = indexPath.row
            return cell
        } //else {
            //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "removeColorCollectionViewCell", for: indexPath) as! RemoveColorCollectionViewCell
            //cell.removeColorButton.tag = indexPath.row
            //return cell
        //}
    }
    
    //MARK: ColorButtonPressed
    @IBAction func colorButtonPressed(_ sender: UIButton) {
        if (color == colors[sender.tag]) {
            //this is the already-selected color; we should instead open an editing view
            let colorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newColorPickerID") as! NewColorPickerViewController
            self.addChild(colorVC)
            colorVC.view.frame = self.view.frame
            self.view.addSubview(colorVC.view)
            colorVC.didMove(toParent: self)
            colorVC.detailController = self
            colorVC.mode = NewColorPickerViewController.Mode.edit
            colorVC.color = color ?? UIColor.white
            colorVC.indexToEdit = sender.tag
            colorVC.removeButton.isHidden = false
        } else {
            color = colors[sender.tag]
            collectionView.reloadData()
        }
        //sender.isSelected = true
        //print(sender.tag)
        //let colorText = colorTexts[sender.tag]
        //print("Color: \(colorText)")
    }
    
    //MARK: NewColorButtonPressed
    @IBAction func newColorButtonPressed(_ sender: UIButton) {
        //print("new color, yay!")
        let colorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newColorPickerID") as! NewColorPickerViewController
        self.addChild(colorVC)
        colorVC.view.frame = self.view.frame
        self.view.addSubview(colorVC.view)
        colorVC.didMove(toParent: self)
        colorVC.detailController = self
        colorVC.mode = NewColorPickerViewController.Mode.new
        colorVC.removeButton.isHidden = true
        //color = colors[sender.tag]
       // collectionView.reloadData()
    }
    
    //MARK: Restoring Data
    func restoreProperties() {
        var name = waypoint?.name ?? "Unnamed Waypoint"
        if nameField.text != "" && nameField.text != nil{
            name = nameField.text!
        }
        //let latitude = Double(latField.text!) ?? waypoint?.location.coordinate.latitude ?? 0.0
        //let longitude = Double(lonField.text!) ?? waypoint?.location.coordinate.longitude ?? 0.0
        let newLatitude = latitude ?? waypoint?.location.coordinate.latitude ?? 0.0
        let newLongitude = longitude ?? waypoint?.location.coordinate.longitude ?? 0.0
        let distance = waypoint?.distance ?? 0.0
        
        waypoint = Waypoint(latitude: newLatitude, longitude: newLongitude, name: name, color: color ?? UIColor.white)
        waypoint?.distance = distance
    }
    
    func loadColors() {
        //print("Loading")
        colors = (NSKeyedUnarchiver.unarchiveObject(withFile: ColorList.ArchiveURL) as? [UIColor]) ?? ColorList.defaultColors
    }
    
    func saveColors() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(colors, toFile: ColorList.ArchiveURL)
        if !isSuccessfulSave {
            print("Failed to save colors!")
        } else {
            //print("Saved!")
        }
    }
    
    //MARK: - Text Field Correction
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if let searchViewController = segue.destination as? SearchViewController {
            //searchViewController.waypoint = waypoint
            ///MARK: Need to pass... latitude and longitude fields?
            //searchViewController.latField = latField
            //searchViewController.lonField = lonField
            searchViewController.detailView = self
            
            return
        }
        
        if let button = sender as? UIButton, button === saveButton {
            restoreProperties()
        } else if let button = sender as? UIButton, button === saveButton_2 {
            restoreProperties()
        /*} else if let button = sender as? UIButton, button === cancelButton_2 {
            waypoint = nil*/
        } else {
            //not the save button!
            //establish that we want to discard this waypoint entirely
            cancel = true
            return
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
