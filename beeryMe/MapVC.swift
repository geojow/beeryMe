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
  var searchRadius = 500
  var numberOfResults = 25
  var noResults = false
  var noLocation = false
  let queryService = QueryService()
  let regionRadius: CLLocationDistance = 500
  
  // MARK: Load Functionality
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUserAlertCorners()
    
    mapView.delegate = self
    if #available(iOS 11.0, *) {
      mapView.register(PubView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    } else {
      // Fallback on earlier versions
    }
    if makeNetworkCall {
      mapView.alpha = 0
    }
    setUpLocationManager()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    froth.frame = CGRect(x: mug.frame.minX + 10, y: mug.frame.minY + 10, width: 95, height: 128)
    if makeNetworkCall {
      mapView.alpha = 1
      startLoading()
    }
  }
  
  func setUserAlertCorners() {
    userAlertLabel.layer.cornerRadius = 20
    userAlertLabel.layer.masksToBounds = true
  }
  
  func startLoading() {
    loadingView.alpha = 0.8
    mug.alpha = 1
    beer.alpha = 1
    froth.alpha = 1
    beeryMe.alpha = 1
    playFizz()
    UIView.animate(withDuration: 5, animations: {
      self.froth.transform = CGAffineTransform(scaleX: 1, y: 1/128)
      self.froth.frame = CGRect(x: self.beer.frame.minX, y: self.beer.frame.minY, width: 95, height: 1)
    }) { finished in
      self.stopLoading()
    }
  }
  
  func stopLoading() {
    loadingView.alpha = 0
    mug.alpha = 0
    beer.alpha = 0
    froth.alpha = 0
    beeryMe.alpha = 0
    if noLocation {
      setUserAlert(for: "location")
      mapView.showsUserLocation = false
    } else if noResults {
      setUserAlert(for: "pubs")
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
        noLocation = true
      }
    }
  }
  
  func centreOnLocation(_ location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                              regionRadius, regionRadius)
    mapView.setRegion(coordinateRegion, animated: true)
    if makeNetworkCall {
      networkCall(location: location, searchRadius: searchRadius, numberOfResults: numberOfResults)
    } else {
      self.mapView.addAnnotations(pubs)
    }
    
  }
  
  func networkCall(location: CLLocation, searchRadius: Int, numberOfResults: Int) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    queryService.getSearchResults(location: location, searchRadius: searchRadius, numberOfResults: numberOfResults) { results, errorMessage in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      if let results = results {
        if results.isEmpty {
          self.noResults = true
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
    userAlertLabel.text = "No \(value) found! Tap back!"
    mapView.alpha = 0.5
    mapView.isUserInteractionEnabled = false
    listButton.isEnabled = false
    listButton.alpha = 0.5
    backButton.pulsate(times: 5)
    userAlertLabel.alpha = 1
  }
  
  // MARK: Audio Functionality
  
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
  
  // MARK: Segue Functionality
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toPubList" {
      let controller = segue.destination as! PubListVC
      controller.pubList = pubs
    }
  }
}

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
