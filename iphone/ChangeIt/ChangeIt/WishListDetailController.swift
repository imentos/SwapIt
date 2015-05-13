//
//  WishListDetail.swift
//  ChangeIt
//
//  Created by i818292 on 4/23/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class WishListDetailController: UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    var wish:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            nameTextField.becomeFirstResponder()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveWishList" {
            wish = nameTextField.text
            PFCloud.callFunction("addWish", withParameters: ["name": nameTextField.text])
            PFCloud.callFunction("linkMyWish", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "wish": nameTextField.text])
        }
    }
}
