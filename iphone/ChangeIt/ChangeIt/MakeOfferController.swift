//
//  OfferController.swift
//  ChangeIt
//
//  Created by i818292 on 5/6/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class MakeOfferController: UITableViewController {
    var itemsJSON:JSON = nil
    var selectedIndex:Int? = nil
    var selectedItem:JSON? = nil
    
    @IBAction func addItem(segue:UIStoryboardSegue) {
        loadData()
    }
    
    @IBAction func cancelItem(segue:UIStoryboardSegue) {
    }
    
    func loadData() {
        PFCloud.callFunctionInBackground("getItemsOfUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!], block: {
            (items:AnyObject?, error: NSError?) -> Void in
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (itemsJSON == nil) {
            return 0
        }
        return itemsJSON.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath) as! UITableViewCell

        PFQuery(className:"Image").getObjectInBackgroundWithId(itemsJSON[indexPath.row]["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            let imageView = cell.viewWithTag(101) as! UIImageView
            imageView.image = UIImage(data: imageData!)
        })

        let label = cell.viewWithTag(102) as! UILabel
        label.text = itemsJSON[indexPath.row]["title"].string

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //Other row is selected - need to deselect it
        if let index = selectedIndex {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            cell?.accessoryType = .None
        }
        
        selectedIndex = indexPath.row
        selectedItem = itemsJSON[selectedIndex!]
        
        //update the checkmark for the current row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
}
