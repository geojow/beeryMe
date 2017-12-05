//
//  PubCell.swift
//  beeryMe
//
//  Created by George Jowitt on 05/12/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit

class PubCell: UITableViewCell {
  
  @IBOutlet weak var pubLabel: UILabel!
  @IBOutlet weak var pubVisitedImage: UIImageView!
  
  func configureCell(pub: Pub) {
    pubLabel.layer.cornerRadius = 20
    pubLabel.layer.masksToBounds = true
    pubLabel.text = pub.name
    configureImageFor(pub: pub)
  }
  
  func configureImageFor(pub: Pub) {
    if pub.visited {
      pubVisitedImage.image = #imageLiteral(resourceName: "beer-visited")
    } else {
      pubVisitedImage.image = #imageLiteral(resourceName: "beer-not-visited")
    }
  }

}
