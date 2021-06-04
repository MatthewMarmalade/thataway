//
//  ColorCollectionViewCell.swift
//  Compass
//
//  Created by Matthew Marsland on 9/3/19.
//  Copyright © 2019 Matthew Marsland. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var colorButton: UIButton!
    
    func displayContent(color : UIColor) {
        colorButton.imageView?.tintColor = color
        //colorButton.imageView?.backgroundColor = color
        //colorButton.imageView
        //imageView.image = image
        //now we have to turn a color into an imageview! yay!
    }
}
