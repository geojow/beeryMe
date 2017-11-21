//
//  ViewController.swift
//  beeryMe
//
//  Created by George Jowitt on 10/02/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation

class OpeningScreenVC: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var background: UILabel!
    @IBOutlet weak var clickPromt: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var bMLabel: UILabel!
    @IBOutlet weak var geojowLbl: UILabel!
    @IBOutlet weak var settings: UIView!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var resultsSlider: UISlider!
    @IBOutlet weak var measurementsButton: UIButton!
    
    // MARK: Variables
    
    var timer = Timer()
    var player = AVAudioPlayer()
    var makeNetworkCall = true
    var radius = 1000.00
    var results = 25
    var units = "km"
    
    // MARK: Load Functionality
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.getRadius() != 0 {
            radius = UserDefaults.standard.getRadius()
        }
        print("saved radius: \(radius)")
        
        if UserDefaults.standard.getNoOfResults() != 0 {
            results = UserDefaults.standard.getNoOfResults()
        }
        print("saved results: \(results)")
        
        if UserDefaults.standard.getUnits() != "" {
            units = UserDefaults.standard.getUnits()
        }
        
        settings.layer.cornerRadius = 30
        button.layer.cornerRadius = 20
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(OpeningScreenVC.waitThenAnimate), userInfo: nil, repeats: false)
        
        button.isEnabled = false
        
    }
    
    @objc func waitThenAnimate() {
        
        perform(#selector(OpeningScreenVC.animate), with: nil, afterDelay: 0.5)
        
    }
        
    @objc func animate() {
        
        UIView.animate(withDuration: 0.9, animations:  {
            self.background.transform = CGAffineTransform(scaleX: 0.26, y: 0.145)
            self.bMLabel.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
            
            self.perform(#selector(OpeningScreenVC.setRoundedCorners), with: nil, afterDelay: 0.1)
            self.perform(#selector(OpeningScreenVC.pulseButton), with: nil, afterDelay: 2)
            self.perform(#selector(OpeningScreenVC.showPromt), with: nil, afterDelay: 4)
            
        })
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(OpeningScreenVC.enableButton), userInfo: nil, repeats: false)
        
    }
    
    @objc func setRoundedCorners() {
        UIView.animate(withDuration: 0.9, animations: {
            self.background.layer.cornerRadius = 65
        })
    }
    
    @objc func pulseButton() {
        
        self.borderPulse(element: bMLabel, fromScale: 0.25, toScale: 0.275)
        self.borderPulse(element: button, fromScale: 1, toScale: 1.1)
        
    }
    
    func borderPulse(element: UIView, fromScale: Float, toScale: Float) {
        
        let scaleAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 0.5
        scaleAnimation.repeatCount = 3.0
        scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = fromScale
        scaleAnimation.toValue = toScale
        element.layer.add(scaleAnimation, forKey: "scale")
        
    }
    
    @objc func showPromt() {
        
        UIView.animate(withDuration: 1, animations: {
            
            self.clickPromt.alpha = 1
        })
        
    }
    
    @objc func enableButton() {
        button.isEnabled = true
    }
    
    // MARK: Button Functionality
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        let audioPath = Bundle.main.path(forResource: "beer", ofType: "mp3")
        do {
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
            
            player.play()
        } catch {
            // Process any errors
        }
        
        UIView.animate(withDuration: 1, animations: {
            self.background.transform = CGAffineTransform(scaleX: 0.21, y: 0.12)
            self.button.transform = CGAffineTransform(scaleX: 0.1, y: 0.05)
            self.bMLabel.transform = CGAffineTransform(scaleX: 0.19, y: 0.19)
            self.clickPromt.alpha = 0
            self.button.alpha=0
            self.geojowLbl.alpha = 0
            
        })
        
        self.perform(#selector(OpeningScreenVC.buttonPressedExpand), with: nil, afterDelay: 0.1)
        
    }
    
    @objc func buttonPressedExpand() {
        self.button.alpha = 0
        
        UIView.animate(withDuration: 2, animations: {
            self.background.transform = CGAffineTransform(scaleX: 1, y: 0.563)
            self.background.alpha = 0
            self.bMLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
            self.bMLabel.alpha = 0
        })
        self.perform(#selector(OpeningScreenVC.goToMap), with: nil, afterDelay: 1)
        
        
    }
    
    @objc func goToMap() {
        
        self.performSegue(withIdentifier: "toMap", sender: self)
        
    }
    
    // MARK: Settings Functionality
    
    @IBAction func settingsPressed(_ sender: UIButton) {
        
        radiusSlider.setValue(Float(radius), animated: false)
        resultsLabel.text = "\(results)"
        resultsSlider.setValue(Float(results), animated: false)
        measurementsButton.layer.cornerRadius = 10
        updateRadiusAndUnitsLabels()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.settings.alpha = 1
            self.backgroundButton.alpha = 1
        })
    }
    
    func updateRadiusAndUnitsLabels() {
        let units = UserDefaults.standard.getUnits()
        measurementsButton.setTitle(units, for: .normal)
        if units == "km" {
            let newKm = String(format: "%.2f", arguments: [radius/1000])
            radiusLabel.text = "\(newKm) km"
        } else {
            let miles = convertToMiles(radius/1000)
            let newMiles = String(format: "%.2f", arguments: [miles])
            radiusLabel.text = "\(newMiles) miles"
        }
    }
    
    func convertToMiles(_ number: Double) -> Double {
        return number * 1.6
    }
    
    @IBAction func dismissSettings(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.settings.alpha = 0
            self.backgroundButton.alpha = 0
            UserDefaults.standard.setRadius(value: self.radius)
            UserDefaults.standard.setNoOfResults(value: self.results)
        })
    }

    @IBAction func radiusSliderMoved(_ sender: UISlider) {
        radius = Double(sender.value)
        updateRadiusAndUnitsLabels()
    }
    
    @IBAction func resultsSliderMoved(_ sender: UISlider) {
        results = lroundf(sender.value)
        resultsLabel.text = "\(results)"
    }
    
    @IBAction func changeUnitsOfMeasurement(_ sender: UIButton) {
        if units == "km" {
            units = "miles"
            UserDefaults.standard.setUnits(value: "miles")
        } else if units == "miles" {
            units = "km"
            UserDefaults.standard.setUnits(value: "km")
        }
        updateRadiusAndUnitsLabels()
    }

    // MARK: Segue Functionality
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap" {
            let controller = segue.destination as! MapVC
            controller.makeNetworkCall = makeNetworkCall
            controller.searchRadius = Int(radius)
            controller.numberOfResults = results
            
        }
    }
    
}

