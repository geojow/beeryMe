//
//  Pubs.swift
//  beeryMe
//
//  Created by George Jowitt on 25/08/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import Foundation
import MapKit

class Pubs: NSObject {
    
    let name: String
    let location: CLLocation
    let visited: Bool
    
    init(name: String, latitude: Double, longitude: Double, visited: Bool) {
        
        self.name = name
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.visited = visited
        
    }
}

extension Pubs: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        get {
            return location.coordinate
        }
    }
    
    var title: String? {
        get {
            return name
        }
    }
    
    var image: UIImage? {
        get {
            if visited {
                return #imageLiteral(resourceName: "beer-visited")
            } else {
                return #imageLiteral(resourceName: "beer-not-visited")
            }
        }
    }
    
}
