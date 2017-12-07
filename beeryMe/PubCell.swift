//
//  PubCell.swift
//  beeryMe
//
//  Created by George Jowitt on 05/12/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit

class PubCell: UITableViewCell {
  
  @IBOutlet weak var pubButton: UIButton!
  @IBOutlet weak var visitedButton: UIButton!
  
  var viewController: PubListVC?
  var pub: Pub! {
    didSet {
      configureCell()
    }
  }
  
  func configureCell() {
    pubButton.titleLabel?.minimumScaleFactor = 0.5
    pubButton.titleLabel?.adjustsFontSizeToFitWidth = true

    pubButton.roundCorners()
    pubButton.setTitle(pub.name, for: .normal)
    
    configureImageFor(pub: pub)
  }
  
  func configureImageFor(pub: Pub) {
    if pub.visited {
      visitedButton.setImage(#imageLiteral(resourceName: "beer-visited"), for: .normal)
    } else {
      visitedButton.setImage(#imageLiteral(resourceName: "beer-not-visited"), for: .normal)
    }
  }
  
  @IBAction func visitedButtonPressed(_ sender: UIButton) {
    pub.toggleVisited()
    UserDefaults.standard.updateWith(pub: pub)
    configureImageFor(pub: pub)
  }
  
  @IBAction func pubButtonPressed(_ sender: UIButton) {
    self.viewController?.setInfoText(pub)
    self.viewController?.showInfoView()
  }
}
