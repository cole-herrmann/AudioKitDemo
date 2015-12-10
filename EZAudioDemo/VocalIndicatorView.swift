//
//  VocalIndicatorView.swift
//  EZAudioDemo
//
//  Created by Cole Herrmann on 11/25/15.
//  Copyright © 2015 Tutor Clan. All rights reserved.
//

import UIKit

class VocalIndicatorView: UIView {

    @IBOutlet weak var centerCircle: UIView!
    @IBOutlet weak var midRing: UIView!
    @IBOutlet weak var outerRing: UIView!
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        outerRing.backgroundColor = .clearColor()
        midRing.backgroundColor = .clearColor()
        backgroundColor = .clearColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        centerCircle.layer.borderColor = UIColor(red:1.000, green:0.475, blue:0.416, alpha: 1).CGColor
        centerCircle.layer.borderWidth = 8
        
        midRing.layer.borderColor = UIColor(red:1.000, green:0.475, blue:0.416, alpha: 1).CGColor
        midRing.layer.borderWidth = 15
        
        centerCircle.layer.cornerRadius = centerCircle.frame.size.width/2
        midRing.layer.cornerRadius = midRing.frame.size.width/2
        outerRing.layer.cornerRadius = outerRing.frame.size.width/2
        layer.cornerRadius = frame.size.width/2
        
       
    }


}
