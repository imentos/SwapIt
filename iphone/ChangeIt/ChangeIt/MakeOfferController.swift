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
//    var selectedIndex:Int? = nil
//    var selectedItem:JSON? = nil
//    var disabledIndex:Int = -1
    var disabledItemId:String!
    var doneButton:UIBarButtonItem?

    var selectedIndexes = Set<String>()

    
    @IBAction func addItem(segue:UIStoryboardSegue) {
        loadData()
    }
    
    @IBAction func cancelItem(segue:UIStoryboardSegue) {
    }
    
    func loadData() {
        PFCloud.callFunctionInBackground("getItemsOfUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!], block: {
            (items:AnyObject?, error: NSError?) -> Void in
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            
            for (var i = 0; i < self.itemsJSON.count; i++) {
                if (self.itemsJSON[i]["objectId"].string == self.disabledItemId) {
                    self.selectedIndexes.insert(self.disabledItemId)
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
        
        doneButton = self.navigationItem.rightBarButtonItem!
        //self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = doneButton
        
        //self.tableView.allowsSelection = false
        self.tableView.allowsMultipleSelection = true
        //self.tableView.allowsMultipleSelectionDuringEditing = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            print("DEL");
        }
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
    
//    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        if (indexPath.row == self.disabledIndex) {
//            return nil
//        }
//        return indexPath
//    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath) as! UITableViewCell
        cell.selectionStyle = .None
        
        if (selectedIndexes.contains(self.itemsJSON[indexPath.row]["objectId"].string!)) {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            cell.accessoryType = .Checkmark
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            cell.accessoryType = .None
        }
        
        
//        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath) as! UITableViewCell
//        if (indexPath.row == self.disabledIndex) {
//            cell.backgroundColor = UIColor.lightGrayColor()
//        }
//
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

        
        
        
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        
//        // deselect old one
//        if let index = selectedIndex {
//            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
//            cell?.accessoryType = .None
//            self.navigationItem.rightBarButtonItem = nil
//        }
//        
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        if (selectedIndex != indexPath.row) {
//            selectedIndex = indexPath.row
//            selectedItem = itemsJSON[selectedIndex!]
//            cell?.accessoryType = .Checkmark
//            self.navigationItem.rightBarButtonItem = doneButton
//        } else {
//            selectedIndex = nil
//        }        
    }
}
