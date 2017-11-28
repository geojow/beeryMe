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
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var mug: UIImageView!
    @IBOutlet weak var froth: UILabel!
    @IBOutlet weak var beer: UIImageView!
    @IBOutlet weak var beeryMe: UILabel!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var userAlertLabel: UILabel!
    
    
    // MARK: Variables & Constants
    
    var makeNetworkCall = true
    var pubs: [Pub] = []
    var player = AVAudioPlayer()
    var timer = Timer()
    var locationManager: CLLocationManager?
    //var startLocation = CLLocation(latitude: 51.47281, longitude: 51.47281)
    var searchRadius = 500
    var numberOfResults = 25
    let queryService = QueryService()
    let regionRadius: CLLocationDistance = 500
    
    // MARK: Load Functionality
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userAlertLabel.layer.cornerRadius = 20
        userAlertLabel.layer.masksToBounds = true
        self.froth.frame = CGRect(x: self.froth.frame.minX, y: self.froth.frame.minY, width: 95, height: 128)
        mapView.delegate = self
        if #available(iOS 11.0, *) {
            mapView.register(PubView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        } else {
            // Fallback on earlier versions
        }
        
        setUpLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if makeNetworkCall {
            startLoading()
        }
    }
    
    func startLoading() {
        loadingView.alpha = 0.8
        mug.alpha = 1
        beer.alpha = 1
        froth.alpha = 1
        beeryMe.alpha = 1
        UIView.animate(withDuration: 5, animations: {
            self.froth.transform = CGAffineTransform(scaleX: 1, y: 1/128)
            self.froth.frame = CGRect(x: self.beer.frame.minX, y: self.beer.frame.minY, width: 95, height: 1)
        })
        
    }
    
    func stopLoading() {
        UIView.animate(withDuration: 1) {
            self.loadingView.alpha = 0
            self.mug.alpha = 0
            self.beer.alpha = 0
            self.froth.alpha = 0
            self.beeryMe.alpha = 0
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
            } else {
                mapView.showsUserLocation = false
                stopLoading()
                setUserAlert(for: "location")
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
        //startLoading()
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
        stopLoading()
    }
    
    func networkCall(location: CLLocation, searchRadius: Int, numberOfResults: Int) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        queryService.getSearchResults(location: location, searchRadius: searchRadius, numberOfResults: numberOfResults) { results, errorMessage in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let results = results {
                if results.isEmpty {
                    self.stopSound()
                    self.setUserAlert(for: "pubs")
                } else {
                    for result in results {
                        self.pubs.append(result)
                    }
                    self.mapView.addAnnotations(results)
                }
            }
            if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
        }
    }
    
    func setUserAlert(for value: String) {
        stopLoading()
        self.userAlertLabel.text = "No \(value) found! Tap back!"
        self.mapView.alpha = 0.5
        self.mapView.isUserInteractionEnabled = false
        self.listButton.isEnabled = false
        self.listButton.alpha = 0.5
        self.backButton.pulsate()
        self.userAlertLabel.alpha = 1
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
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        }
    }
}
