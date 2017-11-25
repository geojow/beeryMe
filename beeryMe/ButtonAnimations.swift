//
//  ButtonAnimations.swift
//  beeryMe
//
//  Created by George Jowitt on 24/11/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func pulsate() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 0.5
        pulse.repeatCount = 4.0
        pulse.autoreverses = true
        pulse.fromValue = 1
        pulse.toValue = 1.1
        layer.add(pulse, forKey: "pulse")
    }
}
