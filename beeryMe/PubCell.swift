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
  
  @IBOutlet weak var pubButton: UIButton!
  @IBOutlet weak var visitedButton: UIButton!
  
  func configureCell(pub: Pub) {
//    pubLabel.layer.cornerRadius = 20
//    pubLabel.layer.masksToBounds = true
//    pubLabel.text = pub.name
    pubButton.layer.cornerRadius = 20
    pubButton.layer.masksToBounds = true
    pubButton.setTitle(pub.name, for: .normal)
    
    configureImageFor(pub: pub)
  }
  
  func configureImageFor(pub: Pub) {
    if pub.visited {
      visitedButton.setImage(#imageLiteral(resourceName: "beer-visited"), for: .normal)
      //pubVisitedImage.image = #imageLiteral(resourceName: "beer-visited")
    } else {
      visitedButton.setImage(#imageLiteral(resourceName: "beer-not-visited"), for: .normal)
      //pubVisitedImage.image = #imageLiteral(resourceName: "beer-not-visited")
    }
  }

}
