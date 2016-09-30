//
//  ViewController.swift
//  ColorPicker
//
//  Created by Matthew Bailey on 9/29/16.
//  Copyright © 2016 Izeni. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSGColorWheelDelegate {

    @IBOutlet weak var colorWheel: NSGColorWheel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var brightnessSlider: UISlider!
    
    var color : UIColor = .white {
        didSet {
            borderView.layer.borderColor = color.cgColor
            brightnessSlider.tintColor = color
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        colorWheel.delegate = self
        
        borderView.layer.masksToBounds = true
        borderView.layer.borderColor = color.cgColor
        borderView.layer.borderWidth = 15
        
        brightnessSlider.tintColor = color
        brightnessSlider.value = 1.0
        brightnessSlider.addTarget(self, action: #selector(brightnessChanged), for: .valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        borderView.layer.cornerRadius = borderView.frame.height / 2
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func colorChanged(color: UIColor) {
        self.color = color.withAlphaComponent(CGFloat(brightnessSlider.value))
    }
    
    func brightnessChanged() {
        color = color.withAlphaComponent(CGFloat(brightnessSlider.value))
    }

}

