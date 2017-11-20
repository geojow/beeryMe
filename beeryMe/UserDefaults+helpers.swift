//
//  UserDefaults+helpers.swift
//  beeryMe
//
//  Created by George Jowitt on 20/11/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    func setRadius(value: Int) {
        set(value, forKey: "radius")
    }
    
    func getRadius() -> Int {
        return integer(forKey: "radius")
    }
    
    func setNoOfResults(value: Int) {
        set(value, forKey: "results")
    }
    
    func getNoOfResults() -> Int {
        return integer(forKey: "results")
    }
    
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
