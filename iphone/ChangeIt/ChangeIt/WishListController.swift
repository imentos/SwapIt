//
//  WishListController.swift
//  ChangeIt
//
//  Created by i818292 on 4/23/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class WishListController: UITableViewController, UITextFieldDelegate {
    var wishesJSON:JSON = nil
    var enableEdit:Bool = true
    var otherWishlist:Bool = true
    var currentWishText:UITextField!
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var toolbar: UINavigationItem!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        let index = NSIndexPath(forRow: 0, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(index) as! AddWishListCell
        let newWishText = cell.newWishListText.text
        if (newWishText!.isEmpty == true) {
            return false
        }
        let wishId = NSUUID().UUIDString
        cell.newWishListText.text = ""
        
        PFCloud.callFunctionInBackground("addWish", withParameters: ["name": newWishText!, "objectId": wishId], block: {
            (wishes:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            PFCloud.callFunctionInBackground("linkMyWish", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "objectId": wishId], block: {
                (wishes:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    return
                }
                self.loadData((PFUser.currentUser()?.objectId)!, otherWishlist: false)
            })
        })
        return true
    }

    @IBAction func deleteAction(sender: AnyObject) {
        var title = ""
        if (self.tableView.indexPathsForSelectedRows?.count == 1) {
            title = "Are you sure you want to remove this item from wish list?"
        } else {
            title = "Are you sure you want to remove all items from your wish list?"
        }
        
        let alert:UIAlertController = UIAlertController(title: "Alert", message: title, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let userId = PFUser.currentUser()?.objectId
            let selectedRows = self.tableView.indexPathsForSelectedRows
            let selectedRowsCount = selectedRows?.count
            if (selectedRowsCount != self.wishesJSON.count) {
                var deleteObjectIds = [String]()
                for var i = 0; i < selectedRows!.count; ++i {
                    let index = selectedRows![i].row - 1
                    let objectId = self.wishesJSON[index]["objectId"].string
                    deleteObjectIds.append(objectId!)
                }
                
                PFCloud.callFunctionInBackground("deleteWishesOfUser", withParameters: ["userId":userId!, "objectIds":deleteObjectIds], block: {
                    (wishes:AnyObject?, error: NSError?) -> Void in
                    if let error = error {
                        NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                        return
                    }
                    self.loadData((PFUser.currentUser()?.objectId)!, otherWishlist: false)
                    self.tableView.editing = false
                })
            } else {
                self.wishesJSON.arrayObject?.removeAll(keepCapacity: false)
                self.tableView.reloadData()
                
                PFCloud.callFunctionInBackground("deleteAllWishesOfUser", withParameters: ["userId":userId!], block: {
                    (wishes:AnyObject?, error: NSError?) -> Void in
                    if let error = error {
                        NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                        return
                    }
                    self.loadData((PFUser.currentUser()?.objectId)!, otherWishlist: false)
                    self.tableView.editing = false
                })
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.tableView.reloadData()

        self.tableView.editing = false
        self.updateButtonsToMatchTableState()
        self.hideAddWishListCell(false)
    }
    
    @IBAction func editAction(sender: AnyObject) {
        self.tableView.reloadData()
        
        self.tableView.editing = true
        self.updateButtonsToMatchTableState()
        self.hideAddWishListCell(true)
    }
    
    func hideAddWishListCell(hidden:Bool) {
        let index = NSIndexPath(forRow: 0, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(index) as! AddWishListCell
        if (hidden == true) {
            cell.endEditing(true)
        }
        cell.hidden = hidden
    }
    
    func updateButtonsToMatchTableState() {
        if (self.tableView.editing) {
            self.navigationItem.rightBarButtonItem = self.deleteButton
            self.navigationItem.leftBarButtonItem = self.cancelButton
            self.updateDeleteButtonTitle()
            
            //self.resignFirstResponder()
            if let _ = currentWishText {
                currentWishText.endEditing(true)
            }

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
        let selectedRows = self.tableView.indexPathsForSelectedRows
        
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

    func loadData(userId:String!, otherWishlist:Bool) {
        PFCloud.callFunctionInBackground("getWishesOfUser", withParameters: ["userId":userId], block: {
            (wishes:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            self.wishesJSON = JSON(data:(wishes as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.otherWishlist = otherWishlist
            self.tableView.reloadData()
            
            self.updateButtonsToMatchTableState()
            self.hideAddWishListCell(otherWishlist)
            
            if (self.enableEdit == false) {
                self.toolbar.rightBarButtonItem = nil
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0 && (self.tableView.editing || self.otherWishlist)) {
            return 0
        }
        return 50
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
            currentWishText = cell.newWishListText
            if (self.otherWishlist == false) {
                currentWishText.becomeFirstResponder()
            }
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("wishList", forIndexPath: indexPath) 
        let wish = cell.viewWithTag(101) as! UILabel
        wish.text = wishesJSON[indexPath.row - 1]["name"].string
        cell.selectionStyle = UITableViewCellSelectionStyle.Default
        
        for c in cell.contentView.constraints {
            if (c.identifier == "leading") {
                c.constant = tableView.editing == true ? 0 : 37
            }
        }
        cell.contentView.updateConstraints()

        
        return cell
    }
}
