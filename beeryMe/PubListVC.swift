//
//  PubListVC.swift
//  beeryMe
//
//  Created by George Jowitt on 09/11/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class PubListVC: UIViewController {
  
  // MARK: IBOutlets
  
  @IBOutlet weak var backgroundButton: UIButton!
  @IBOutlet weak var info: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var pubName: UILabel!
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var websiteButton: UIButton!
  
  // MARK: Variables & Constants
  
  var userLocation: CLLocation?
  var pubList: [Pub] = []
  var makeNetworkCall = false
  let cellSpacingHeight: CGFloat = 5.0
  var currentPub: Pub?
  
  // MARK: Load Functionality
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delaysContentTouches = true
    tableView.canCancelContentTouches = true
    info.layer.cornerRadius = 30
    setUpRightSwipt()
  }
  
  func setUpRightSwipt() {
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
    rightSwipe.direction = .right
    view.addGestureRecognizer(rightSwipe)
  }
  
  @objc func handleSwipes(sender:UISwipeGestureRecognizer) {
    if (sender.direction == .right) {
      self.performSegue(withIdentifier: "toMapFromList", sender: self)
    }
  }
  
  // MARK: Info Functionality
  
  func showInfoView() {
    UIView.animate(withDuration: 0.5, animations: {
      self.info.alpha = 1
      self.backgroundButton.alpha = 0.9
    })
  }
  
  @IBAction func backgroundButtonClicked(_ sender: UIButton) {
    UIView.animate(withDuration: 0.5, animations: {
      self.info.alpha = 0
      self.backgroundButton.alpha = 0
    })
  }
  
  @IBAction func goToMapsApp(_ sender: UIButton) {
    if let location = currentPub {
      let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
      location.mapItem().openInMaps(launchOptions: launchOptions)
    }
  }
  
  @IBAction func websiteButtonPressed(_ sender: Any) {
    if let website = currentPub?.website, let url = URL(string: website) {
      let safariVC = SFSafariViewController(url: url)
      present(safariVC, animated: true, completion: nil)
    }
  }
  
  // MARK: Segue Functionality
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toMapFromList" {
      let controller = segue.destination as! MapVC
      controller.pubs = pubList
      controller.makeNetworkCall = makeNetworkCall
      controller.userLocation = userLocation
    }
  }
  
}

extension PubListVC: PubCellDelegate {
  func showInfoFor(pub: Pub) {
    currentPub = pub
    pubName.text = pub.name
    address.text = pub.formattedAddress
    if pub.website != "" {
      websiteButton.roundCorners()
      websiteButton.alpha = 1
    } else {
      websiteButton.alpha = 0
    }
    showInfoView()
  }
}


// MARK: UITableViewDataSource
extension PubListVC: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return pubList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    currentPub = pubList[indexPath.section]
    let cell = tableView.dequeueReusableCell(withIdentifier: "pubItem", for: indexPath) as! PubCell
    cell.pub = pubList[indexPath.section]
    cell.delegate = self
    //cell.viewController = self
    cell.selectionStyle = UITableViewCellSelectionStyle.none
    return cell
  }
}

// MARK: UITableViewDelegate
extension PubListVC: UITableViewDelegate {

}




