//
//  WishListController.swift
//  ChangeIt
//
//  Created by i818292 on 4/23/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class WishListController: UITableViewController, UIActionSheetDelegate {
    var wishesJSON:JSON = nil
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var toolbar: UINavigationItem!
    
    @IBAction func addAction(sender: AnyObject) {
        let index = NSIndexPath(forRow: 0, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(index) as! AddWishListCell
        let newWishText = cell.newWishListText.text
        cell.newWishListText.text = ""
        
        PFCloud.callFunctionInBackground("addWish", withParameters: ["name": newWishText], block: {
            (wishes:AnyObject?, error: NSError?) -> Void in
            PFCloud.callFunctionInBackground("linkMyWish", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "wish": newWishText], block: {
                (wishes:AnyObject?, error: NSError?) -> Void in
                self.loadData((PFUser.currentUser()?.objectId)!, hideAddCell: false)
            })
        })
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
        var title = ""
        if (self.tableView.indexPathsForSelectedRows()?.count == 1) {
            title = "Are you sure you wnat to remove this wish list?"
        } else {
            title = "Are you sure you want to remove these wish lists?"
        }
        let actionSheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "OK")
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            let userId = PFUser.currentUser()?.objectId
            let selectedRows = self.tableView.indexPathsForSelectedRows()
            let deleteSpecificRows = selectedRows?.count > 0;
            if (deleteSpecificRows) {
                for var i = 0; i < selectedRows!.count; ++i {
                    let index = selectedRows![i].row - 1
                    let wish = self.wishesJSON[index]["name"].string
                    self.wishesJSON.arrayObject?.removeAtIndex(index)
                    
                    PFCloud.callFunctionInBackground("deleteWishOfUser", withParameters: ["userId":userId!, "wish":wish!], block: {
                        (wishes:AnyObject?, error: NSError?) -> Void in
                    })
                }
                
                self.tableView.deleteRowsAtIndexPaths(selectedRows!, withRowAnimation: UITableViewRowAnimation.Automatic)
            } else {
                self.wishesJSON.arrayObject?.removeAll(keepCapacity: false)
                self.tableView.reloadData()
                
                PFCloud.callFunctionInBackground("deleteAllWishesOfUser", withParameters: ["userId":userId!], block: {
                    (wishes:AnyObject?, error: NSError?) -> Void in
                })
            }
            
            self.tableView.editing = false
            self.updateButtonsToMatchTableState()
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.tableView.editing = false
        self.updateButtonsToMatchTableState()
        
        hideAddWishListCell(false)
    }
    
    @IBAction func editAction(sender: AnyObject) {
        self.tableView.editing = true
        self.updateButtonsToMatchTableState()
        
        hideAddWishListCell(true)
    }
    
    func hideAddWishListCell(hidden:Bool) {
        let index = NSIndexPath(forRow: 0, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(index) as! AddWishListCell
        cell.hidden = hidden
    }
    
    func updateButtonsToMatchTableState() {
        if (self.tableView.editing) {
            self.navigationItem.rightBarButtonItem = self.deleteButton
            self.navigationItem.leftBarButtonItem = self.cancelButton
            self.updateDeleteButtonTitle()
        } else {
            if self.wishesJSON.count > 0 {
                self.editButton.enabled = true;
            } else {
                self.editButton.enabled = false;
            }
            self.navigationItem.leftBarButtonItem = self.backButton
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

    func loadData(userId:String!, hideAddCell:Bool) {
        var wishesJSON:JSON!
        PFCloud.callFunctionInBackground("getWishesOfUser", withParameters: ["userId":userId], block: {
            (wishes:AnyObject?, error: NSError?) -> Void in
            self.wishesJSON = JSON(data:(wishes as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
            
            self.updateButtonsToMatchTableState()
            self.hideAddWishListCell(hideAddCell)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            self.wishesJSON.arrayObject?.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (wishesJSON == nil) {
            return 0
        }
        return wishesJSON.count + 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddWishListCell", forIndexPath: indexPath) as! AddWishListCell
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("wishList", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = wishesJSON[indexPath.row - 1]["name"].string
        
        
        return cell
    }
}
