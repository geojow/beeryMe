//
//  ViewController.swift
//  beeryMe
//
//  Created by George Jowitt on 10/02/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController {

    @IBOutlet weak var background: UILabel!
    @IBOutlet weak var clickPromt: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var bMLabel: UILabel!
    @IBOutlet weak var geojowLbl: UILabel!
    
    var timer = Timer()
    
    
    
    func waitThenAnimate() {
        
        perform(#selector(ViewController.animate), with: nil, afterDelay: 0.5)
        
    }
    
    func animate() {
        
        UIView.animate(withDuration: 0.9, animations:  {
            self.background.transform = CGAffineTransform(scaleX: 0.26, y: 0.145)
            self.bMLabel.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
           
            self.perform(#selector(ViewController.setRoundedCorners), with: nil, afterDelay: 0.1)
            self.perform(#selector(ViewController.pulseButton), with: nil, afterDelay: 2)
            self.perform(#selector(ViewController.showPromt), with: nil, afterDelay: 4)
            
        })
        
    
    }
    
    func pulseButton() {
        
        self.borderPulse(element: bMLabel, fromScale: 0.25, toScale: 0.275)
        self.borderPulse(element: button, fromScale: 1, toScale: 1.1)
        
    }
    
    func showPromt() {
        
        UIView.animate(withDuration: 1, animations: {
            
            self.clickPromt.alpha = 1
        })
        button.isEnabled = true
    }
    
    func setRoundedCorners() {
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
        
        UIView.animate(withDuration: 1, animations: {
            self.background.transform = CGAffineTransform(scaleX: 0.21, y: 0.12)
            self.button.transform = CGAffineTransform(scaleX: 0.1, y: 0.05)
            self.bMLabel.transform = CGAffineTransform(scaleX: 0.19, y: 0.19)
            self.clickPromt.alpha = 0
            self.button.alpha=0
            self.geojowLbl.alpha = 0
        
        })
        
       self.perform(#selector(ViewController.buttonPressedExpand), with: nil, afterDelay: 0.1)
        
    }
    
    func buttonPressedExpand() {
        self.button.alpha = 0
        
        UIView.animate(withDuration: 2, animations: {
            self.background.transform = CGAffineTransform(scaleX: 1, y: 0.563)
            self.background.alpha = 0
            self.bMLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
            self.bMLabel.alpha = 0
        })
        self.perform(#selector(ViewController.goToMap), with: nil, afterDelay: 1)
        
        
    }
    
     func goToMap() {
        
        self.performSegue(withIdentifier: "toMap", sender: self)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.waitThenAnimate), userInfo: nil, repeats: false)
        self.button.layer.cornerRadius = 20
        button.isEnabled = false
        
    }

    
     // not sure what this is here for, havent used/needed it yet
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

