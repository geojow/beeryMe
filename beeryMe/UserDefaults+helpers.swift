//
//  UserDefaults+helpers.swift
//  beeryMe
//
//  Created by George Jowitt on 20/11/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import Foundation

extension UserDefaults {
  func setRadius(value: Double) {
    set(value, forKey: "radius")
  }
  
  func getRadius() -> Double {
    return double(forKey: "radius")
  }
  
  func setUnits(value: String) {
    set(value, forKey: "units")
  }
  
  func getUnits() -> String {
    if let units = string(forKey: "units") {
      return units
    } else {
      return "km"
    }
  }
  
  // TODO - Delete this
  
  func setNoOfResults(value: Int) {
    set(value, forKey: "results")
  }
  
  func getNoOfResults() -> Int {
    return integer(forKey: "results")
  }
  
  /////////////////
  
  func addPub(id: String) {
    set(id, forKey: "\(id)")
  }
  
  func isPubWithIdInUserDefaults(id: String) -> Bool {
    if string(forKey: "\(id)") != nil {
      return true
    } else {
      return false
    }
  }
  
  func updateWith(pub: Pub) {
    if pub.visited {
      addPub(id: "\(pub.id)")
    } else {
      removeObject(forKey: "\(pub.id)")
    }
  }
}
