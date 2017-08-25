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
            annotationView?.leftCalloutAccessoryView = UIImageView(image: image)
        }
        
        return annotationView
    }
}
