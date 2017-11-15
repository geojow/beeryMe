//
//  PubListVC.swift
//  beeryMe
//
//  Created by George Jowitt on 09/11/2017.
//  Copyright © 2017 George Jowitt. All rights reserved.
//

import UIKit

class PubListVC: UITableViewController {
    
    //var pubsVisited: [Int] = []
    var pubList: [Pub] = []
    let cellSpacingHeight: CGFloat = 5.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRightSwipt()
        self.navigationController?.hidesBarsOnSwipe = false
        
        
        
        
       

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return pubList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let pub = pubList[indexPath.section]
            pub.toggleVisited()
            configureImage(for: cell, with: pub)
//            if pub.visited && !pubsVisited.contains(pub.id) {
//                pubsVisited.append(pub.id)
//            } else if !pub.visited && pubsVisited.contains(pub.id) {
//                let index = pubsVisited.index(of: pub.id)
//                pubsVisited.remove(at: index!)
//            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
}
