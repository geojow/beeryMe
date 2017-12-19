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
  @IBOutlet weak var clickPrompt: UILabel!
  @IBOutlet weak var button: UIButton!
  @IBOutlet weak var geojowLbl: UILabel!
  @IBOutlet weak var settings: UIView!
  @IBOutlet weak var radiusLabel: UILabel!
  @IBOutlet weak var radiusSlider: UISlider!
  @IBOutlet weak var measurementsButton: UIButton!
  @IBOutlet weak var soundsButton: UIButton!
  @IBOutlet weak var settingsButton: UIButton!
  @IBOutlet weak var refreshButton: UIButton!
  
  // MARK: Variables
  
  var timer = Timer()
  var player = AVAudioPlayer()
  var locationManager: CLLocationManager?
  var userLocation: CLLocation?
  var makeNetworkCall = true
  var radius = 1495.00
  var units = "km"
  var soundOn = true
  var screen = CGRect()
  var screenWidth: CGFloat = 0
  var screenHeight: CGFloat = 0
  
  // MARK: Load Functionality
  
  override func viewDidLoad() {
    super.viewDidLoad()
    connectionCheck()
    getScreenSize()
    setUpButton()
    getUserDefaults()
    setCorners()
    setUpLocationManager()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    animate()
  }
  
  func connectionCheck() {
    if ConnectionCheck.isConnectedToNetwork() {
      button.alpha = 1
      refreshButton.alpha = 0
      clickPrompt.text = "CLICK BOX FOR BEER"
    } else {
      button.alpha = 0
      refreshButton.alpha = 1
      clickPrompt.alpha = 1
      clickPrompt.text = "No internet connection!"
    }
  }
  
  func getScreenSize() {
    screen = UIScreen.main.bounds
    screenWidth = screen.width
    screenHeight = screen.height
  }
  
  func setUpButton() {
    button.titleLabel?.font = button.titleLabel?.font.withSize(100)
    button.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
  }
  
  func getUserDefaults() {
    let launchedBefore = UserDefaults.standard.bool(forKey:"HasLaunchedOnce")
    if launchedBefore {
      radius = UserDefaults.standard.getRadius()
      units = UserDefaults.standard.getUnits()
      soundOn = UserDefaults.standard.getSoundOn()
    } else {
      UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
    }
    let soundsSetting = UserDefaults.standard.object(forKey: "soundOn")
    if soundsSetting == nil {
      UserDefaults.standard.setSoundOn(value: true)
    }
  }
  
  func setCorners() {
    settings.layer.cornerRadius = 30
    button.layer.cornerRadius = 5
    refreshButton.layer.cornerRadius = 20
  }
  
  func setUpLocationManager() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    locationManager?.requestWhenInUseAuthorization()
  }
  
  func animate() {
    UIView.animate(withDuration: 0.9, delay: 0.6, options: .curveLinear, animations: {
      self.button.titleLabel?.adjustsFontSizeToFitWidth = true
      self.button.titleLabel?.font = self.button.titleLabel?.font.withSize(25)
      self.button.frame = CGRect(x: (self.screenWidth/2)-45, y: (self.screenHeight/2)-45, width: 90, height: 90)
      self.button.layer.cornerRadius = 20
    }, completion: { finished in
      self.button.pulsate(times: 3)
      self.showPromt()
    })
  }
  
  func showPromt() {
    UIView.animate(withDuration: 1, delay: 4, options: .curveLinear, animations: {
      self.clickPrompt.alpha = 1
    }, completion: nil)
  }
  
  @IBAction func refreshButtonPressed(_ sender: UIButton) {
    connectionCheck()
  }
  
  // MARK: Button Functionality
  
  @IBAction func buttonPressed(_ sender: UIButton) {
    UIView.animate(withDuration: 0.5, animations: {
      self.clickPrompt.alpha = 0
      self.geojowLbl.alpha = 0
      self.settingsButton.alpha = 0
    })
    sender.layer.removeAllAnimations()
    if soundOn {
      playSound()
    }
    buttonPressedExpand()
  }
  
  func playSound() {
    let audioPath = Bundle.main.path(forResource: "beer", ofType: "mp3")
    do {
      try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
      player.play()
    } catch {
      // Process any errors
    }
  }
  
  func buttonPressedExpand() {
    UIView.animate(withDuration: 2, delay: 0.1, options: .curveLinear, animations: {
      self.button.transform = CGAffineTransform(scaleX: 5, y: 5)
      self.button.alpha = 0
    }, completion: { finished in
      self.goToMap()
    })
  }
  
  func goToMap() {
    self.performSegue(withIdentifier: "toMap", sender: self)
  }
  
  // MARK: Settings Functionality
  
  @IBAction func settingsPressed(_ sender: UIButton) {
    radiusSlider.setValue(Float(radius), animated: false)
    measurementsButton.layer.cornerRadius = 10
    soundsButton.layer.cornerRadius = 10
    updateRadiusAndUnitsLabels()
    updateSounds()
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
  
  func updateSounds() {
    let soundOn = UserDefaults.standard.getSoundOn()
    if soundOn {
      soundsButton.setTitle("on", for: .normal)
    } else {
      soundsButton.setTitle("off", for: .normal)
    }
  }
  
  func convertToMiles(_ number: Double) -> Double {
    return number / 1.6
  }
  
  @IBAction func dismissSettings(_ sender: UIButton) {
    UIView.animate(withDuration: 0.5, animations: {
      self.settings.alpha = 0
      self.backgroundButton.alpha = 0
    })
    saveSettings()
  }
  
  @IBAction func radiusSliderMoved(_ sender: UISlider) {
    radius = Double(sender.value)
    updateRadiusAndUnitsLabels()
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
  
  @IBAction func toggleSounds(_ sender: UIButton) {
    soundOn = !soundOn
    UserDefaults.standard.setSoundOn(value: soundOn)
    updateSounds()
  }
  
  func saveSettings() {
    UserDefaults.standard.setRadius(value: radius)
    UserDefaults.standard.setSoundOn(value: soundOn)
  }
  
  // MARK: Segue Functionality
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toMap" {
      saveSettings()
      UserDefaults.standard.set(false, forKey: "searchThisArea")
      let controller = segue.destination as! MapVC
      controller.makeNetworkCall = makeNetworkCall
      controller.searchRadius = Int(radius)
      controller.userLocation = userLocation
      controller.soundOn = soundOn
    }
  }
}

extension OpeningScreenVC: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      locationManager?.startUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    userLocation = locations[0]
  }
}
