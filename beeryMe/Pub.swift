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
  var geocoder: CLGeocoder?
  
  var formattedAddress = ""
  var website = ""
  var street = ""
  
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
      return location.coordinate
  }
  
  var title: String? {
      return name
  }
  
  var image: UIImage? {
      if visited {
        return #imageLiteral(resourceName: "beer-visited")
      } else {
        return #imageLiteral(resourceName: "beer-not-visited")
      }
  }
  
  func mapItem() -> MKMapItem {
    let addressDict = [CNPostalAddressStreetKey: street]
    let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = title
    return mapItem
  }
}

extension Pub {
  
  func getAddress() {
    if geocoder == nil {
      geocoder = CLGeocoder()
    }
    geocoder?.reverseGeocodeLocation(location, completionHandler: { (placemark, error) in
      
      if let placemark = placemark?.first {
        if let streetNumber = placemark.subThoroughfare {
          self.formattedAddress += streetNumber + " "
        }
        if let streetName = placemark.thoroughfare {
          self.formattedAddress += streetName + "\n"
        }
        if let city = placemark.locality {
          self.formattedAddress += city + "\n"
        }
        if let postcode = placemark.postalCode {
          self.formattedAddress += postcode
        }
      } else {
        self.formattedAddress = "No address found"
      }
    })
  }
}
