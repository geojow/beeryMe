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
    @IBAction func radiusSliderMoved(_ sender: UISlider) {
        radius = lroundf(sender.value)
        radiusLabel.text = "\(radius)m"
    }
    @IBAction func resultsSliderMoved(_ sender: UISlider) {
        results = lroundf(sender.value)
        resultsLabel.text = "\(results)"
    }
    
    var timer = Timer()
    var player = AVAudioPlayer()
    var makeNetworkCall = true
    
    var radius = 1000
    var results = 25
    // TEMP /////

    var tempPubList: [Pub] = []

    /////////////
    
    @IBAction func settingsPressed(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.settings.alpha = 1
            self.backgroundButton.alpha = 1
            })
        
    }
    
    @IBAction func dismissSettings(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.settings.alpha = 0
            self.backgroundButton.alpha = 0
        })
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
    
    @objc func enableButton() {
        button.isEnabled = true
    }
    
    @objc func pulseButton() {
        
        self.borderPulse(element: bMLabel, fromScale: 0.25, toScale: 0.275)
        self.borderPulse(element: button, fromScale: 1, toScale: 1.1)
        
    }
    
    @objc func showPromt() {
        
        UIView.animate(withDuration: 1, animations: {
            
            self.clickPromt.alpha = 1
        })
        
    }
    
    @objc func setRoundedCorners() {
        UIView.animate(withDuration: 0.9, animations: {
         self.background.layer.cornerRadius = 65
        })
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap" {
            let controller = segue.destination as! MapVC
            controller.makeNetworkCall = makeNetworkCall
            controller.searchRadius = radius
            controller.numberOfResults = results

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settings.layer.cornerRadius = 30

        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(OpeningScreenVC.waitThenAnimate), userInfo: nil, repeats: false)
        self.button.layer.cornerRadius = 20
        button.isEnabled = false
        
    }



}

