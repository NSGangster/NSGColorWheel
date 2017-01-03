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
        let generator = ColorWheelGenerator(delegate: self)
        generator.drawColorWheel()
        
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
        
        print(angle)
        
        let x = center.x + dist * sin(angle)
        let y = center.y + dist * cos(angle)
        
        selectorView.frame.origin.x = x - (selectorHeight / 2)
        selectorView.frame.origin.y = y - (selectorHeight / 2)
        
        let midPoint = CGPoint(x: selectorView.frame.midX, y: selectorView.frame.midY)
        
        setColorForSelector(position: midPoint)
    }
    
    func setColorForSelector(position : CGPoint) {
        selectedColor = self.getUIColorForPointCoordinate(point: position)
    }
    
    
}

extension NSGColorWheel : ColorWheelGeneratorDelegate {
    internal var pixelWidth: Int {
        get {
            let scale = UIScreen.main.scale
            return Int(scale * self.frame.width)
        }
        
    }
    
    internal var pixelHeight: Int {
        get {
            let scale = UIScreen.main.scale
            return Int(scale * self.frame.height)
        }
        
    }
    
    internal var pixelRadius: Int {
        get {
            return (pixelWidth > pixelHeight ? pixelHeight : pixelWidth) / 2
        }
        
    }
    
    func colorWheelImageDidFinishLoading(with colorWheelImage: UIImage) {
        self.image = colorWheelImage
    }
    
    func getRGBForPixelCoordinate(x: Int, y: Int) -> RGB32 {
        
        let centerX = pixelWidth / 2
        let centerY = pixelHeight / 2
        
        let dx = Double(abs(centerX - x))
        let dy = Double(abs(y - centerY))
        var angle = atan(dy / dx)
        let radius = Double(pixelRadius)
        
        if angle.isNaN {
            angle = 0.0
        }
        
        let dist = sqrt(pow(dx, 2) + pow(dy, 2))
        
        if x < centerX {
            angle = (M_PI) - angle
        }
        
        if y > centerY {
            angle = 2 * (M_PI) - angle
        }
        
        if angle >= 0 && angle < (2 * M_PI / 3) {
            angle = angle / 2
        } else if angle >= (2 * M_PI / 3) && angle < (3 * M_PI / 2) {
            angle -= (M_PI / 3) * 7 / 6
            
            angle = angle * 6 / 5
        } else if angle >= (3 * M_PI / 2) {
            angle -= (M_PI / 2)
            angle = angle * 4 / 3
            
        }
        
        angle = angle / (2 * M_PI)
        
        
        if dist >= radius {
            return RGB(r: 0, g: 0, b: 0, a: 0).rgb32
        } else {
            let hsv = HSV(h: CGFloat(angle), s: CGFloat(dist / radius), v: CGFloat(1), a: CGFloat(1))
            return hsv.rgbValue.rgb32
        }
        
    }
    
    func getUIColorForPointCoordinate(point: CGPoint) -> UIColor {
        let scale = UIScreen.main.scale
        
        let relativeX =  point.x * scale
        let relativeY = point.y * scale
        
        let rgb32 = getRGBForPixelCoordinate(x: Int(relativeX), y: Int(relativeY))
        let rgb = RGB(r: Double(rgb32.r) / 255.0, g: Double(rgb32.g) / 255.0, b: Double(rgb32.b) / 255.0, a: Double(rgb32.a) / 255.0)
        
        return rgb.uiColor
    }
    
}

protocol ColorWheelGeneratorDelegate {
    var pixelRadius : Int { get }
    var pixelWidth : Int { get }
    var pixelHeight : Int { get }
    
    func colorWheelImageDidFinishLoading(with colorWheelImage: UIImage)
    func getRGBForPixelCoordinate(x: Int, y: Int) -> RGB32
    func getUIColorForPointCoordinate(point: CGPoint) -> UIColor
}

class ColorWheelGenerator : NSObject {
    
    init(delegate: ColorWheelGeneratorDelegate) {
        
        self.delegate = delegate
        self.bytesPerPixel = 4
        self.totalBytes = bytesPerPixel * delegate.pixelHeight * delegate.pixelWidth
        
        super.init()
    }
    
    let bytesPerPixel : Int
    
    var totalBytes : CLong
    
    var delegate : ColorWheelGeneratorDelegate
    
    func drawColorWheel() {
        
        DispatchQueue.global().async {
            
            let context = self.getRGBABitmapContext()
            
            guard let data = context.data else {
                fatalError("Error with image data. Pixels may be 0")
                
            }
            
            let bitmap = data.bindMemory(to: UInt8.self, capacity: self.totalBytes)
            
            var offset = 0
            
            for y in 0 ..< self.delegate.pixelHeight {
                
                for x in 0 ..< self.delegate.pixelWidth {
                    
                    let rgb = self.delegate.getRGBForPixelCoordinate(x: x, y: y)
                    bitmap[offset] = rgb.a
                    bitmap[offset + 1] = rgb.r
                    bitmap[offset + 2] = rgb.g
                    bitmap[offset + 3] = rgb.b
                    
                    offset += self.bytesPerPixel
                }
                
            }
            
            
            let bitmapBytesPerRow = self.delegate.pixelWidth * self.bytesPerPixel
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            guard let colorWheelContext = CGContext(data: bitmap, width: self.delegate.pixelWidth, height: self.delegate.pixelHeight, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
                fatalError("Error creating image context. Pixels may be 0")
            }
            
            guard let image = colorWheelContext.makeImage() else {
                fatalError("Error creating image from context. Pixels may be 0")
                
            }
            
            let colorWheelImage = UIImage(cgImage: image)
            
            DispatchQueue.main.async {
                self.delegate.colorWheelImageDidFinishLoading(with: colorWheelImage)
            }
        }
    }
    
    
    func getRGBABitmapContext() -> CGContext {
        
        let bytesPerRow = bytesPerPixel * delegate.pixelWidth
        
        let totalBytes = bytesPerRow * delegate.pixelHeight
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapData = malloc(totalBytes)
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        guard let context = CGContext(data: bitmapData, width: delegate.pixelWidth, height: delegate.pixelHeight, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            fatalError("Error creating image context. Pixels may be 0")
        }
        
        return context
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
