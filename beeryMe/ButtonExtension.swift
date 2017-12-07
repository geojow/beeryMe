//
//  ButtonExtension.swift
//  beeryMe
//
//  Created by George Jowitt on 24/11/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit

extension UIButton {
  func pulsate(times: Float) {
    let pulse = CABasicAnimation(keyPath: "transform.scale")
    pulse.duration = 0.5
    pulse.repeatCount = times
    pulse.autoreverses = true
    pulse.fromValue = 1
    pulse.toValue = 1.1
    layer.add(pulse, forKey: "pulse")
  }
  
  func roundCorners() {
    layoutIfNeeded()
    layer.cornerRadius = frame.size.height/2
    layer.masksToBounds = true
  }
  
}
