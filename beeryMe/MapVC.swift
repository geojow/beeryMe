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
    
    // MARK: IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Variables & Constants
    
    var makeNetworkCall = true
    var pubs: [Pub] = []
    var player = AVAudioPlayer()
    var timer = Timer()
    var locationManager: CLLocationManager?
    var startLocation = CLLocation(latitude: 51.47281, longitude: 51.47281)
    var searchRadius = 500
    var numberOfResults = 25
    let queryService = QueryService()
    let regionRadius: CLLocationDistance = 500
    
    // MARK: Load Functionality
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setUpLocationManager()
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
    
    func centreOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        if makeNetworkCall {
            playFizz()
            networkCall(location: location, searchRadius: searchRadius, numberOfResults: numberOfResults)
        } else {
            self.mapView.addAnnotations(pubs)
        }
        
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
    
    func networkCall(location: CLLocation, searchRadius: Int, numberOfResults: Int) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        queryService.getSearchResults(location: location, searchRadius: searchRadius, numberOfResults: numberOfResults) { results, errorMessage in
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
    
    // MARK: Segue Functionality
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPubList" {
            let controller = segue.destination as! PubListVC
            controller.pubList = pubs
        }
    }
}

    // TODO - Look at this when look at MapKit tutorial

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "pub"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
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
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "maps-icon"), for: UIControlState())
            annotationView?.rightCalloutAccessoryView = mapsButton
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
                
                if let annotation = view.annotation {
                    if let pub = annotation as? Pub {
                        pub.toggleVisited()
                        UserDefaults.standard.updateWith(pub: pub)
                    }
                }
            }
        }
        
        if control == view.rightCalloutAccessoryView {
            let location = view.annotation as! Pub
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
            location.mapItem().openInMaps(launchOptions: launchOptions)
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
