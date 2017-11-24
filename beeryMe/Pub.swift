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
    
    // TODO - Look at these, do they need to be here?
    var formattedAddress: String = "Address:\n"
    var website: String = "Website:\nNo website found!"
    var street: String = ""
    
    init(id: String, name: String, latitude: Double, longitude: Double, visited: Bool) {
        self.id = id
        self.name = name
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.visited = visited
        
        super.init()
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
    
    var image: UIImage? {
        get {
            if visited {
                return #imageLiteral(resourceName: "beer-visited")
            } else {
                return #imageLiteral(resourceName: "beer-not-visited")
            }
        }
    }

    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: street]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
}
