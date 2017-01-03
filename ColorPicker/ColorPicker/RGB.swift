//
//  HSV.swift
//  ColorPicker
//
//  Created by Matthew Bailey on 10/9/16.
//  Copyright © 2016 Izeni. All rights reserved.
//

import Foundation
import Darwin
import UIKit

struct RGB32 {
    var r : UInt8
    var g : UInt8
    var b : UInt8
    var a : UInt8
}

class RGB : NSObject {
    
    var r : Double = 1
    var g : Double = 1
    var b : Double = 1
    var a : Double = 1
    
    init(r: Double, g: Double, b: Double, a: Double) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        
        super.init()
    }
    
    convenience init(color : UIColor) {
        var x = CGFloat(1)
        var y = CGFloat(1)
        var z = CGFloat(1)
        var w = CGFloat(1)
        
        color.getRed(&x, green: &y, blue: &z, alpha: &w)
        
        self.init(r: Double(x), g: Double(y), b: Double(z), a: Double(w))
    }
    
    convenience init(hsv : HSV) {
        
        self.init(color: hsv.uiColor)
        
    }
    
    var uiColor : UIColor {
        get{
            return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
        }
    }
    
    var hsvValue : HSV {
        get {
            return HSV(color: self.uiColor)
        }
    }
    
    var rgb32 : RGB32 {
        get {
            return RGB32(r: UInt8(r * 255), g: UInt8(g * 255), b: UInt8(b * 255), a: UInt8(a * 255))
        }
    }
}

class HSV : NSObject {
    
    var h : CGFloat = 1
    var s : CGFloat = 1
    var v : CGFloat = 1
    var a : CGFloat = 1
    
    init(h: CGFloat, s: CGFloat, v: CGFloat, a: CGFloat) {
        
        self.h = h
        self.s = s
        self.v = v
        self.a = a
        
        super.init()
    }
    
    convenience init(color : UIColor) {
        var x = CGFloat(1)
        var y = CGFloat(1)
        var z = CGFloat(1)
        var w = CGFloat(1)
        
        color.getHue(&x, saturation: &y, brightness: &z, alpha: &w)
        
        self.init(h: x, s: y, v: z, a: w)
    }
    
    convenience init(rgb : RGB) {
        self.init(color: rgb.uiColor)
    }
    
    var uiColor : UIColor {
        get{
            return UIColor(hue: h, saturation: s, brightness: v, alpha: a)
        }
    }
    
    var rgbValue : RGB {
        get {
            return RGB(color: self.uiColor)
        }
    }

    
}

//extension UIColor {
//    
//    func convertAlphaIntoBrightness() -> RGB {
//        
//        var h = CGFloat(1)
//        var s = CGFloat(1)
//        var v = CGFloat(1)
//        var a = CGFloat(1)
//        
//        self.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
//        
//        v = a
//        
//        let convertedColor = UIColor(hue: h, saturation: s, brightness: v, alpha: 1.0)
//        
//        var r = CGFloat(1)
//        var g = CGFloat(1)
//        var b = CGFloat(1)
//        
//        convertedColor.getRed(&r, green: &g, blue: &b, alpha: &a)
//        
//        return RGB(r: Double(r), g: Double(g), b: Double(b), a: 1.0)
//    }
//    
//}
