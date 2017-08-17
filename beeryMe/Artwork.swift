//
//  Artwork.swift
//  HonoluluArt
//
//  Created by George Jowitt on 08/08/2017.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class Artwork: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    init?(json: [Any]) {
        //1
        self.title = json[1] as? String ?? "No Title"
        self.locationName = json[2] as! String
        self.discipline = json[8] as! String
        //2
        if let latitude = Double(json[6] as! String), let longitude = Double(json[7] as! String) {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
        print(self.coordinate)

    }
  
    var subtitle: String? {
        return locationName
    }
    
    // annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }

    var imageName: String? {
        return "Beer"
    }
    
    
}

