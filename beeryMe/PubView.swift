//
//  PubViews.swift
//  beeryMe
//
//  Created by George Jowitt on 23/11/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import Foundation
import MapKit

class PubView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            
            guard let pub = newValue as? Pub else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            
            if let pubImage = pub.image {
                image = pubImage
            } else {
                image = nil
            }
            
            let btn = UIButton(type: .infoLight)
            btn.setImage(image, for: .normal)
            btn.tintColor = nil
            leftCalloutAccessoryView = btn
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "maps-icon"), for: UIControlState())
            rightCalloutAccessoryView = mapsButton
        }
    }
}

