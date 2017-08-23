//
//  MapViewViewController.swift
//  beeryMe
//
//  Created by George Jowitt on 22/08/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit
import MapKit

class MapViewViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    @IBOutlet weak var mapView: MKMapView!
    var startLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        
        
        let regionRadius: CLLocationDistance = 250
        let region = MKCoordinateRegionMakeWithDistance((startLocation?.coordinate)!, regionRadius, regionRadius)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
        
        
        
    }

    


}

extension MapViewViewController: CLLocationManagerDelegate {
   
}

extension MapViewViewController: MKMapViewDelegate {
    
}
