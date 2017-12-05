//
//  PubListVC.swift
//  beeryMe
//
//  Created by George Jowitt on 09/11/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit
import MapKit

class PubListVC: UIViewController {
  
  // MARK: IBOutlets
  
  @IBOutlet weak var backgroundButton: UIButton!
  @IBOutlet weak var info: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var pubName: UILabel!
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var website: UITextView!
  
  // MARK: Variables & Constants
  
  var pubList: [Pub] = []
  var makeNetworkCall = false
  let cellSpacingHeight: CGFloat = 5.0
  var currentPub: Pub?
  
  // MARK: Load Functionality
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
  
  func setInfoText(_ indexPath: IndexPath) {
    let pub = pubList[indexPath.section]
    pubName.text = pub.name
    address.text = pub.formattedAddress
    website.text = pub.website
  }
  
  @IBAction func goToMapsApp(_ sender: UIButton) {
    if let location = currentPub {
      let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
      location.mapItem().openInMaps(launchOptions: launchOptions)
    }
  }
  
  // MARK: Segue Functionality
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toMapFromList" {
      let controller = segue.destination as! MapVC
      controller.pubs = pubList
      controller.makeNetworkCall = makeNetworkCall
    }
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "pubItem", for: indexPath) as! PubCell
    
    cell.configureCell(pub: pubList[indexPath.section])

    cell.selectionStyle = UITableViewCellSelectionStyle.none
    
    return cell
  }
}

// MARK: UITableViewDelegate
extension PubListVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return cellSpacingHeight
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    currentPub = pubList[indexPath.section]
    setInfoText(indexPath)
    showInfoView()
    tableView.deselectRow(at: indexPath, animated: false)
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let visited = pubList[indexPath.section].visited
    let updateVisited = UITableViewRowAction(style: .normal, title: (visited ? "Visited" : "Not Visited")) { (action, indexPath) in
      if let cell = tableView.cellForRow(at: indexPath) as? PubCell {
        let pub = self.pubList[indexPath.section]
        pub.toggleVisited()
        UserDefaults.standard.updateWith(pub: pub)
        cell.configureImageFor(pub: pub)
      }
    }
    return [updateVisited]
  }
}




