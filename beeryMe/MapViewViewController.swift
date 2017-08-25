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
    
    var pubs: [Pubs] = []
    
    var locationManager: CLLocationManager?
    @IBOutlet weak var mapView: MKMapView!
    var startLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let testPub = Pubs(name: "Willow Tree Inn", latitude: 53.881056, longitude: -1.8839149, visited: false)
        pubs.append(testPub)
        
        
        let regionRadius: CLLocationDistance = 250
        let region = MKCoordinateRegionMakeWithDistance((startLocation?.coordinate)!, regionRadius, regionRadius)
        mapView.setRegion(region, animated: true)
        mapView.delegate = self
        mapView.addAnnotations(pubs)
        
    }

}

extension MapViewViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pub") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pub")
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.canShowCallout = true
        if let pub = annotation as? Pubs,
            let image = pub.image {
            //annotationView?.detailCalloutAccessoryView = UIImageView(image: image)
            let btn = UIButton(type: .infoLight)
            btn.setImage(image, for: .normal)
            btn.tintColor = nil
            annotationView?.leftCalloutAccessoryView = btn
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
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
