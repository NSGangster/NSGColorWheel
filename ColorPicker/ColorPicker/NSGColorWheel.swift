//
//  ColorTileView.swift
//  ColorPicker
//
//  Created by Matthew Bailey on 9/29/16.
//  Copyright © 2016 Izeni. All rights reserved.
//

import Foundation
import Darwin
import UIKit

protocol NSGColorWheelDelegate {
    func colorChanged(color : UIColor) 
}

class NSGColorWheel : UIImageView {
    var delegate : NSGColorWheelDelegate? = nil
    var selectorView : UIView = UIView()
    let selectorHeight = CGFloat(20)
    var isInitialLoad = true
    var selectedColor : UIColor? = .white {
        didSet {
            if let color = selectedColor {
                if let colorDelegate = delegate {
                    colorDelegate.colorChanged(color: color)
                }
            } else {
                backgroundColor = .white
            }
        }
    }
    
    //Make sure colorWheel width == height
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        contentMode = .scaleAspectFit
        image = UIImage(named: "ColorWheel")
        backgroundColor = .gray
        layer.masksToBounds = true

        selectorView.layer.masksToBounds = true
        selectorView.layer.borderColor = UIColor.white.cgColor
        selectorView.layer.borderWidth = 1

        self.clipsToBounds = false
        isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        selectorView.layer.cornerRadius = selectorHeight / 2

        if isInitialLoad {
            isInitialLoad = false
            selectorView.frame = CGRect(x: (frame.width / 2) - selectorHeight / 2, y: (frame.height / 2) - selectorHeight / 2, width: selectorHeight, height: selectorHeight)
            addSubview(selectorView)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let mousePoint = firstTouch.location(in: self)
            var offsetPoint = mousePoint
            offsetPoint.x += frame.origin.x
            offsetPoint.y += frame.origin.y
            
            if frame.contains(offsetPoint) {
                updateSelectorView(point: mousePoint)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let mousePoint = firstTouch.location(in: self)
            var offsetPoint = mousePoint
            offsetPoint.x += frame.origin.x
            offsetPoint.y += frame.origin.y
            
            updateSelectorView(point: mousePoint)
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let mousePoint = firstTouch.location(in: self)

            
                updateSelectorView(point: mousePoint)
        }
        
    }
    
    func updateSelectorView(point : CGPoint) {

        let center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        
        let radius = frame.height * 0.5
        
        let dx = abs(point.x - center.x)
        let dy = abs(point.y - center.y)
        var angle = atan(dy / dx)
        
        if angle.isNaN {
            angle = 0.0
        }
        
        var dist = sqrt(pow(dx, 2) + pow(dy, 2))
        
        if dist > radius {
            dist = radius - 1
        }
        
        if point.x < center.x {
            angle = CGFloat(M_PI) - angle
        }
        
        if point.y > center.y {
            angle = 2 * CGFloat(M_PI) - angle
        }
        
        angle += CGFloat(M_PI) * 0.5
        
        let x = center.x + dist * sin(angle)
        let y = center.y + dist * cos(angle)
        
        selectorView.frame.origin.x = x - (selectorHeight / 2)
        selectorView.frame.origin.y = y - (selectorHeight / 2)
        
        let midPoint = CGPoint(x: selectorView.frame.midX, y: selectorView.frame.midY)

        setColorForSelector(position: midPoint)
    }
    
    func setColorForSelector(position : CGPoint) {
        selectedColor = self.image?.getPixelColor(pos: position, imageViewFrame: frame)
    }

}

let colorWheelPixels : CGFloat = 730.0

extension UIImage {
    func getPixelColor(pos: CGPoint, imageViewFrame: CGRect) -> UIColor {
        
        let relativeX =  pos.x * colorWheelPixels / imageViewFrame.width
        let relativeY = pos.y * colorWheelPixels / imageViewFrame.height
        
        let pixelCoordinate = CGPoint(x: relativeX, y: relativeY)
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let bytesPerPixel = 4
        let pixelIndex: Int = ((Int(colorWheelPixels) * Int(pixelCoordinate.y)) + Int(pixelCoordinate.x)) * bytesPerPixel
        
        let r = CGFloat(data[pixelIndex]) / CGFloat(255.0)
        let g = CGFloat(data[pixelIndex+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelIndex+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelIndex+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }  
}
