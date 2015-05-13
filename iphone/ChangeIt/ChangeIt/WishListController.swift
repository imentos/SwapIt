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
    
    func loadData(userId:String!) {
        var wishesJSON:JSON!
        PFCloud.callFunctionInBackground("getWishesOfUser", withParameters: ["userId":userId], block: {
            (wishes:AnyObject?, error: NSError?) -> Void in
            self.wishesJSON = JSON(data:(wishes as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
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
