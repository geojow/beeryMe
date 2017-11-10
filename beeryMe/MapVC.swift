//
//  MapVC.swift
//  beeryMe
//
//  Created by George Jowitt on 22/08/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//
import Foundation
import UIKit
import MapKit

class MapVC: UIViewController {
    
    var pubs: [Pub] = []
    let queryService = QueryService()
    
    
    var locationManager: CLLocationManager?
    @IBOutlet weak var mapView: MKMapView!
    var startLocation = CLLocation(latitude: 51.47281, longitude: 51.47281)
    let regionRadius: CLLocationDistance = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        
        setUpMapView()
        setUpLocationManager()
        
//        let testPub1 = Pub(name: "Hope & Anchor", latitude: 51.47281, longitude: 51.47281, visited: false)
//        let testPub2 = Pub(name: "The Swan", latitude: 51.47281, longitude: 51.47281, visited: false)
//        let testPub3 = Pub(name: "The Sunningdale Lounge", latitude: 51.47281, longitude: 51.47281, visited: false)
//        let testPub4 = Pub(name: "The Gramby", latitude: 51.47281, longitude: 51.47281, visited: false)
//        let testPub5 = Pub(name: "The Goat Rodeo", latitude: 51.47281, longitude: 51.47281, visited: false)
//        pubs = [testPub1, testPub2, testPub3, testPub4, testPub5]
//        
        
        
    }
    
    func setUpMapView() {
        mapView.delegate = self
    }
    
    func centreOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
        regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        networkCall(location: location)
    }
    
    func setUpLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.startUpdatingLocation()
            if let location = locationManager?.location {
                centreOnLocation(location)
            }
        }
    }
    
    func networkCall(location: CLLocation) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        queryService.getSearchResults(location: location) { results, errorMessage in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let results = results {
                for result in results {
                    self.pubs.append(result)
                }
                self.mapView.addAnnotations(results)
            }
            if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPubList" {
            let controller = segue.destination as! PubListVC
            controller.pubList = pubs
        }
    }
}



extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pub")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pub")
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.canShowCallout = true
        if let pub = annotation as? Pub,
            let image = pub.image {
            let btn = UIButton(type: .infoLight)
            btn.setImage(image, for: .normal)
            btn.tintColor = nil
            annotationView?.leftCalloutAccessoryView = btn
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            annotationView?.image = UIImage(named: "beer-not-visited")
        }
        
        
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.leftCalloutAccessoryView {
            if let button = control as? UIButton {
                if button.currentImage == #imageLiteral(resourceName: "beer-not-visited") {
                    let image = #imageLiteral(resourceName: "beer-visited")
                    button.setImage(image, for: .normal)
                } else if button.currentImage == #imageLiteral(resourceName: "beer-visited") {
                    let image = #imageLiteral(resourceName: "beer-not-visited")
                    button.setImage(image, for: .normal)
                }
            }
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
    }
}
