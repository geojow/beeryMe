//
//  Pubs.swift
//  beeryMe
//
//  Created by George Jowitt on 25/08/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class Pub: NSObject {
    
    
    let id: String
    let name: String
    let location: CLLocation
    var visited: Bool
    
    init(id: String, name: String, latitude: Double, longitude: Double, visited: Bool) {
        self.id = id
        self.name = name
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.visited = visited
        
    }
    
    func toggleVisited() {
        visited = !visited
    }
}

extension Pub: MKAnnotation {
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
    

    // TODO - Move this to somewhere more appropriate, model should not have anything to do with view
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
