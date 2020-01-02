//
//  ColorList.swift
//  Compass
//
//  Created by Matthew Marsland on 1/1/20.
//  Copyright © 2020 Tectane. All rights reserved.
//

import UIKit

class ColorList: NSObject, NSCoding {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("colorFiles").path
    
    var colorList : [UIColor]
    static let defaultColors : [UIColor] = [UIColor.red, UIColor.blue, UIColor.green, UIColor.white, UIColor.orange, UIColor.brown, UIColor.cyan, UIColor.gray, UIColor.purple, UIColor.yellow]
    
    struct Keys {
        static let colorsKey = "colorsKey"
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.colorList, forKey: Keys.colorsKey)
    }
    
    required init?(coder: NSCoder) {
        let colors = coder.decodeObject(forKey: Keys.colorsKey) as? [UIColor]
        colorList = colors ?? ColorList.defaultColors
    }
    
}
