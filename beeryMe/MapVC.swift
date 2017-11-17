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
import AVFoundation

class MapVC: UIViewController {
    
    var makeNetworkCall = true
    
    
    //var pubsVisited: [Int] = []
    var pubs: [Pub] = []
    let queryService = QueryService()
    var player = AVAudioPlayer()
    var timer = Timer()
    
    
    var locationManager: CLLocationManager?
    @IBOutlet weak var mapView: MKMapView!
    var startLocation = CLLocation(latitude: 51.47281, longitude: 51.47281)
    let regionRadius: CLLocationDistance = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("make network call: \(makeNetworkCall)")
        //pubs = []
        setUpMapView()
        setUpLocationManager()
    }
    
    func playFizz() {
        let audioPath = Bundle.main.path(forResource: "beerpour", ofType: "mp3")
        do {
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
            
            player.play()
        } catch {
            // Process any errors
        }
        timer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(MapVC.stopSound), userInfo: nil, repeats: false)
    }
    
    @objc func stopSound() {
        player.stop()
    }
    
    func setUpMapView() {
        mapView.delegate = self
    }
    
    func centreOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
        regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        if makeNetworkCall {
            playFizz()
            networkCall(location: location)
        } else {
            print("Adding pubs from array")
            self.mapView.addAnnotations(pubs)
        }
        
    }
    
    func setUpLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.distanceFilter = 50
        
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
                    print(result.id)
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
            //controller.pubsVisited = pubsVisited
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
            if pub.visited {
                annotationView?.image = UIImage(named: "beer-visited")
            } else {
                annotationView?.image = UIImage(named: "beer-not-visited")
            }
        }
        
        
        
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.leftCalloutAccessoryView {
            if let button = control as? UIButton {
                if button.currentImage == #imageLiteral(resourceName: "beer-not-visited") {
                    let image = #imageLiteral(resourceName: "beer-visited")
                    button.setImage(image, for: .normal)
                    view.image = UIImage(named: "beer-visited")
                } else if button.currentImage == #imageLiteral(resourceName: "beer-visited") {
                    let image = #imageLiteral(resourceName: "beer-not-visited")
                    button.setImage(image, for: .normal)
                    view.image = UIImage(named: "beer-not-visited")
                }
                
                // toggle visited from map
                
                if let annotation = view.annotation {
                    print("\(annotation)")
                    if let pub = annotation as? Pub {
                        print("toggle visited")
                        pub.toggleVisited()
                    }
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
