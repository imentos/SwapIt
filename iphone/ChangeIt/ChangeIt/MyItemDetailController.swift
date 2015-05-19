//
//  MyItemDetailController.swift
//  ChangeIt
//
//  Created by i818292 on 5/19/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit

class MyItemDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var questionsJSON:JSON = nil
    var items: [String] = ["Viper", "X", "Games"]
    
    @IBOutlet var detailTable: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBAction func indexChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            testLabel.text = "First selected";
            
            items = ["Vipe1r1", "X11", "G1ames1"]
            
//            detailTable.
        case 1:
            testLabel.text = "Second Segment selected";
            items = ["Viper1", "X1", "Games1"]
        default: 
            break; 
        }
        self.detailTable.reloadData()
    }
    
    @IBOutlet var testLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadData() {
        //self.detailTable.
        self.detailTable.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
//        if (questionsJSON == nil) {
//            return 0
//        }
//        return 2//questionsJSON.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myItemDetail", forIndexPath: indexPath) as! UITableViewCell
//        let offerJSON = offersJSON[indexPath.row]
//        
//        PFQuery(className:"Image").getObjectInBackgroundWithId(offerJSON["src"]["photo"].string!, block: {
//            (imageObj:PFObject?, error: NSError?) -> Void in
//            let imageData = (imageObj!["file"] as! PFFile).getData()
//            (cell.viewWithTag(101) as! UIImageView).image = UIImage(data: imageData!)
//        })
//        
//        let label = cell.viewWithTag(102) as! UILabel
//        label.text = offerJSON["src"]["title"].string
        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }

}
