//
//  MapViewController.swift
//  beeryMe
//
//  Created by George Jowitt on 21/08/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit
import CoreLocation

class MapViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    var startLocation: CLLocation?
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first
        } else {
            guard let latest = locations.first else { return }
            latitudeLabel.text = "latitude: \(latest.coordinate.latitude)"
            longitudeLabel.text = "longitude \(latest.coordinate.longitude)"
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        <#code#>
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
    }
}
