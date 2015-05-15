//
//  WishListController.swift
//  ChangeIt
//
//  Created by i818292 on 4/23/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class WishListController: UITableViewController {
    var wishesJSON:JSON = nil
    
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var toolbar: UINavigationItem!
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func save(segue:UIStoryboardSegue) {
         if let detailController = segue.sourceViewController as? WishListDetailController {
            PFCloud.callFunctionInBackground("getWishesOfUser", withParameters: ["userId":(PFUser.currentUser()?.objectId)!], block: {
                (wishes:AnyObject?, error: NSError?) -> Void in
                self.wishesJSON = JSON(data:(wishes as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                
                let indexPath = NSIndexPath(forRow: self.wishesJSON.count-1, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            })
        }
    }
    
    @IBAction func deleteAction(sender: AnyObject) {
        
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.tableView.editing = false
        self.updateButtonsToMatchTableState()
    }
    
    @IBAction func editAction(sender: AnyObject) {
        self.tableView.editing = true
        self.updateButtonsToMatchTableState()
    }
    
    func updateButtonsToMatchTableState() {
        if (self.tableView.editing) {
            self.navigationItem.rightBarButtonItem = self.cancelButton
            self.updateDeleteButtonTitle()
            self.navigationItem.leftBarButtonItem = self.deleteButton
            
        } else {
            self.navigationItem.leftBarButtonItem = self.addButton;
            
            // Show the edit button, but disable the edit button if there's nothing to edit.
            if self.wishesJSON.count > 0 {
                self.editButton.enabled = true;
            } else {
                self.editButton.enabled = false;
            }
            self.navigationItem.rightBarButtonItem = self.editButton;
        }
    }
    
    func updateDeleteButtonTitle() {
        let selectedRows = self.tableView.indexPathsForSelectedRows()
        
        let allItemsAreSelected = selectedRows == nil ? false : selectedRows!.count == self.wishesJSON.count
        let noItemsAreSelected = selectedRows == nil ? true :selectedRows!.count == 0
        
        if (allItemsAreSelected || noItemsAreSelected) {
            self.deleteButton.title = "Delete All"
        } else {
            self.deleteButton.title = String(format: "Delete (%d)", selectedRows!.count)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        updateDeleteButtonTitle()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        updateDeleteButtonTitle()
    }

    func loadData(userId:String!) {
        var wishesJSON:JSON!
        PFCloud.callFunctionInBackground("getWishesOfUser", withParameters: ["userId":userId], block: {
            (wishes:AnyObject?, error: NSError?) -> Void in
            self.wishesJSON = JSON(data:(wishes as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
            
            self.updateButtonsToMatchTableState()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // called when a row deletion action is confirmed
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            // remove the deleted item from the model
            self.wishesJSON.arrayObject?.removeAtIndex(indexPath.row)
            
            // remove the deleted item from the `UITableView`
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        default:
            return
        }
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
        if (wishesJSON == nil) {
            return 0
        }
        return wishesJSON.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("test", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = wishesJSON[indexPath.row]["name"].string
        return cell
    }
}
