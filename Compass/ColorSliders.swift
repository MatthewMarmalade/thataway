//
//  ColorSliders.swift
//  Compass
//
//  Created by Matthew Marsland on 12/31/19.
//  Copyright © 2019 Tectane. All rights reserved.
//

import UIKit

@IBDesignable
class ColorSliders: UIView {
    
    let saturationExponentTop:Float = 2.0
    let saturationExponentBottom:Float = 1.3
    @IBInspectable var hue : CGFloat = 0.5
    @IBInspectable var barSize : CGFloat = 0.0
    @IBInspectable var elementSize : CGFloat = 1.0
    
    private func initialize() {
         self.clipsToBounds = true
         //let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.touchedColor(gestureRecognizer:)))
         //touchGesture.minimumPressDuration = 0
         //touchGesture.allowableMovement = CGFloat.greatestFiniteMagnitude
         //self.addGestureRecognizer(touchGesture)
     }

    override init(frame: CGRect) {
         super.init(frame: frame)
         initialize()
     }

     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         initialize()
     }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        var saturation : CGFloat = 1.0 //increases with x
        var brightness : CGFloat = 0.0 //decreases with y
        var barHue : CGFloat = 0.0 //increases with x

        for y : CGFloat in stride(from: 0.0 ,to: rect.height - barSize, by: elementSize) {
            brightness = CGFloat(rect.height - y) / rect.height
            for x : CGFloat in stride(from: 0.0 ,to: rect.width, by: elementSize) {
                //hue = x / rect.width
                saturation = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x:x, y:y, width:elementSize,height:elementSize))
            }
        }
        for x : CGFloat in stride(from: 0.0, to: rect.width, by: elementSize) {
            saturation = CGFloat(1.0)
            brightness = CGFloat(1.0)
            barHue = x / rect.width
            let color = UIColor(hue: barHue, saturation: saturation, brightness: brightness, alpha: 1.0)
            context!.setFillColor(color.cgColor)
            context!.fill(CGRect(x:x, y:rect.height-barSize, width:elementSize,height:barSize))
        }
    }
    
    func extractColor(x : CGFloat, y : CGFloat, rect : CGRect) -> UIColor {
        let tapSaturation : CGFloat = x / rect.width
        let tapBrightness : CGFloat = CGFloat(rect.height - y) / rect.height
        let tapHue = hue
        let tapColor = UIColor(hue:tapHue, saturation:tapSaturation, brightness:tapBrightness, alpha:1.0)
        return tapColor
    }
    

}
