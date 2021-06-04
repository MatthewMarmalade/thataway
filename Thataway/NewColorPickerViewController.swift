//
//  NewColorPickerViewController.swift
//  Compass
//
//  Created by Matthew Marsland on 12/30/19.
//  Copyright © 2019 Matthew Marsland. All rights reserved.
//

import UIKit

class NewColorPickerViewController: UIViewController {

    
    @IBOutlet weak var colorPane: ColorSliders!
    @IBOutlet weak var colorSlider: UISlider!
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var removeButton: UIButton!
    
    var color : UIColor = UIColor.white
    @IBOutlet weak var colorPreview: UIImageView!
    
    
    
    var detailController : WaypointDetailViewController?
    var cancelling = false
    
    var indexToEdit : Int?
    
    enum Mode {
        case edit
        case new
    }
    var mode : Mode = Mode.new
    
    var x : CGFloat = 0.0
    var y : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tint out the rest of the screen
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        // Do any additional setup after loading the view.
        colorSlider.isContinuous = false
        //color = colorPane.extractColor(x: x, y: y, rect: colorPane.frame)
        
    }
    
    @IBAction func tapPane(_ sender: Any) {
        x = tapGesture.location(in: colorPane).x
        y = tapGesture.location(in: colorPane).y
        //print("x: \(x), y: \(y)")
        color = colorPane.extractColor(x: x, y: y, rect: colorPane.frame)
        colorPreview.tintColor = color 
    }
    
    @IBAction func colorChanged(_ sender: Any) {
        //print("hi!")
        colorPane.hue = CGFloat(colorSlider.value)
        //colorPane.draw(colorPane.frame)
        colorPane.setNeedsDisplay()
        color = colorPane.extractColor(x: x, y: y, rect: colorPane.frame)
        colorPreview.tintColor = color 
    }
    
    // MARK: - Navigation
    
    @IBAction func cancelColor(_ sender: Any) {
        //how do we get this triggered by tapping outside the popup?
        //detailController?.colors.removeLast()
        self.view.removeFromSuperview()
    }
    
    @IBAction func saveColor(_ sender: Any) {
        //pass back to the main detail!
        if (mode == Mode.new) {
            detailController?.colors.append(color)
            detailController?.color = color
        } else if (mode == Mode.edit) {
            detailController?.color = color
            detailController?.colors[indexToEdit ?? 0] = color
        }
        detailController?.collectionView.reloadData()
        detailController?.saveColors()
        self.view.removeFromSuperview()
    }
    
    @IBAction func removeColor(_ sender: Any) {
        //pass back to the main detail, while also removing this color from the list!
        let totalColors = detailController?.colors.count ?? 1
        if (totalColors > 1) {
            var newIndex : Int = 0
            let oldIndex = indexToEdit ?? 0
            if (oldIndex == totalColors - 1) {
                newIndex = oldIndex - 1
            } else if (oldIndex < totalColors - 1) {
                newIndex = oldIndex + 1
            }
            detailController?.color = detailController?.colors[newIndex]
            detailController?.colors.remove(at: oldIndex)
        }
        detailController?.collectionView.reloadData()
        detailController?.saveColors()
        self.view.removeFromSuperview()
    }

}
