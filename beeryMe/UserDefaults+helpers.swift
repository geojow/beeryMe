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
    
}
