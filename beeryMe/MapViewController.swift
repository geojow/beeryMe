//
//  MapViewController.swift
//  beeryMe
//
//  Created by George Jowitt on 21/08/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    var startLocation: CLLocation?
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var geocoder: CLGeocoder?
    
    func lookupGeoCoding(userLocation: CLLocation) {
        
        if geocoder == nil {
            geocoder = CLGeocoder()
        }
        
        geocoder?.reverseGeocodeLocation(userLocation, completionHandler: { (placemark, error) in
            let placemark = placemark?.first
            let streetNumber = placemark?.subThoroughfare
            let streetName = placemark?.thoroughfare
            let city = placemark?.locality
            let state = placemark?.administrativeArea
            
            let address = "\(streetNumber!)\n\(streetName!)\n\(city!)\n\(state!)"
            
            self.addressLabel.text = address
        })
        
    }
    
    
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
    
    @IBAction func goToActualMap(_ sender: Any) {
            self.performSegue(withIdentifier: "toActualMap", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toActualMap" {
            if let destinationViewController = segue.destination as? MapViewViewController {
                destinationViewController.startLocation = startLocation
            }
        }
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first
        } else {
            guard let latest = locations.first else { return }
            latitudeLabel.text = "latitude: \(latest.coordinate.latitude)"
            longitudeLabel.text = "longitude \(latest.coordinate.longitude)"
            lookupGeoCoding(userLocation: latest)
         
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
    }
}
