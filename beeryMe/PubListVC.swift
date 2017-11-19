//
//  PubListVC.swift
//  beeryMe
//
//  Created by George Jowitt on 09/11/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit

class PubListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var info: UIView!
    //var pubsVisited: [Int] = []
    var pubList: [Pub] = []
    let cellSpacingHeight: CGFloat = 5.0
    var makeNetworkCall = false
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pubName: UILabel!
    
    /// info labels
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var website: UITextView!
    
    
    @IBAction func backgroundButtonClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.info.alpha = 0
            self.backgroundButton.alpha = 0
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        info.layer.cornerRadius = 30
        setUpRightSwipt()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return pubList.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func setInfo(_ indexPath: IndexPath) {
        let pub = pubList[indexPath.section]
        pubName.text = pub.name
        address.text = pub.formattedAddress
        website.text = pub.website
        
//        /// Double Tap
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PubListVC.doubleTapHandler(_:cellForRowAt:)))
//        doubleTap.numberOfTapsRequired = 2
//        pubName.addGestureRecognizer(doubleTap)
//        ///////////
    
    }
    
//    @objc func doubleTapHandler(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) {
//        print("double tap")
//        print(tableView)
//        print(indexPath)
//        if let cell = tableView.cellForRow(at: indexPath) {
//            let pub = pubList[indexPath.section]
//            pub.toggleVisited()
//            configureImage(for: cell, with: pub)
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let pub = pubList[indexPath.section]
//            pub.toggleVisited()
//            configureImage(for: cell, with: pub)
            setInfo(indexPath)
            UIView.animate(withDuration: 0.5, animations: {
                self.info.alpha = 1
                self.backgroundButton.alpha = 0.9
            })
////            if pub.visited && !pubsVisited.contains(pub.id) {
////                pubsVisited.append(pub.id)
////            } else if !pub.visited && pubsVisited.contains(pub.id) {
////                let index = pubsVisited.index(of: pub.id)
////                pubsVisited.remove(at: index!)
////            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
   

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pubItem", for: indexPath)
        let label = cell.viewWithTag(1000) as! UILabel
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        let pub = pubList[indexPath.section]
        configureText(for: cell, with: pub)
        configureImage(for: cell, with: pub)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func configureText(for cell: UITableViewCell, with item: Pub) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.name
    }
    
    func configureImage(for cell: UITableViewCell, with item: Pub) {
        let image = cell.viewWithTag(1001) as! UIImageView
        if item.visited {
            image.image = #imageLiteral(resourceName: "beer-visited")
        } else {
            image.image = #imageLiteral(resourceName: "beer-not-visited")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapFromList" {
            let controller = segue.destination as! MapVC
            controller.pubs = pubList
            //controller.pubsVisited = pubsVisited
            controller.makeNetworkCall = makeNetworkCall
        }
    }

    
 /////// LEFT Swipe gesture
    
    func setUpRightSwipt() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .right) {
            print("Left Swipe!")
            
            self.performSegue(withIdentifier: "toMapFromList", sender: self)
        }
    }
    
    ///////////////////////
    
    /////// Right swipe on cells
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    let visited = pubList[indexPath.section].visited
  
    let updateVisited = UITableViewRowAction(style: .normal, title: (visited ? "Visited" : "Not Visited")) { (action, indexPath) in
    // code to implement the status update goes here
        print("right swipe on cell!")
        if let cell = tableView.cellForRow(at: indexPath) {
            let pub = self.pubList[indexPath.section]
            pub.toggleVisited()
            self.configureImage(for: cell, with: pub)
        }
    }
    
    return [updateVisited]
    }
    
    ////////////////////
}


