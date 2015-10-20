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
    var currentItemId:String!
    var selectedIndexes = Set<String>()
    
    @IBAction func addItem(segue:UIStoryboardSegue) {
        loadData()
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
    }
    
    func loadData() {
        PFCloud.callFunctionInBackground("getItemsOfUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!], block: {
            (items:AnyObject?, error: NSError?) -> Void in
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            
            for (var i = 0; i < self.itemsJSON.count; i++) {
                if (self.itemsJSON[i]["objectId"].string == self.currentItemId) {
                    self.selectedIndexes.insert(self.currentItemId)
                    break
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath) 
        cell.selectionStyle = .None
        
        if (selectedIndexes.contains(self.itemsJSON[indexPath.row]["objectId"].string!)) {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            cell.accessoryType = .Checkmark
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            cell.accessoryType = .None
        }
        
        createImageQuery().getObjectInBackgroundWithId(itemsJSON[indexPath.row]["photo"].string!, block: {
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
        selectedIndexes.insert(itemsJSON[indexPath.row]["objectId"].string!)
        
        if (selectedIndexes.count > 1) {
            selectedIndexes.removeAll(keepCapacity: false)
            selectedIndexes.insert(itemsJSON[indexPath.row]["objectId"].string!)
            self.tableView.reloadData()
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell!.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexes.remove(itemsJSON[indexPath.row]["objectId"].string!)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell!.accessoryType = .None
    }
}
