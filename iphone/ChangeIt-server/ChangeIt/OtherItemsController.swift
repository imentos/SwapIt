//
//  OffersDetailController.swift
//  ChangeIt
//
//  Created by i818292 on 5/7/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class OtherItemsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var userJSON:JSON!
    var itemsJSON:JSON!
    
    @IBOutlet weak var itemCount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        print("cancel")
    }
    
    @IBAction func reportUser(sender: AnyObject) {
        let alert:UIAlertController = UIAlertController(title: "Alert", message: "Are you sure you want to report this user as abusive user?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes, I do.", style: .Default, handler: { (action) -> Void in
            let spinner = createSpinner(self.view)
            PFCloud.callFunctionInBackground("flagUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "otherUserId": (self.userJSON["objectId"].string)!], block:{
                (items:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    spinner.stopAnimating()
                    return
                }
                spinner.stopAnimating()
            })
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.userName.text = self.userJSON["name"].string!
        
        displayUserPhoto(self.userPhoto, userJSON: self.userJSON)
    }
    
    func loadData() {
        let userId = self.userJSON["objectId"].string!
        let spinner = createSpinner(self.view)
        PFCloud.callFunctionInBackground("getItemsByUser", withParameters: ["userId": userId], block: {
            (items:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                spinner.stopAnimating()
                return
            }
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.itemCount.text = "\(self.itemsJSON.count)"
            self.tableView.reloadData()
            spinner.stopAnimating()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = itemsJSON {
            return itemsJSON.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath) 
        let itemJSON = itemsJSON[indexPath.row]
        
        createImageQuery().getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            do {
            let imageData = try (imageObj!["file"] as! PFFile).getData()
            let imageView = cell.viewWithTag(101) as! UIImageView
            imageView.image = UIImage(data: imageData)
            } catch {}
        })
        
        let label = cell.viewWithTag(102) as! UILabel
        label.text = itemJSON["title"].string
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detail") {
            let selectedIndex = self.tableView.indexPathForSelectedRow?.row
            
            let detail = segue.destinationViewController as! ItemDetailController
            detail.fromOtherItems = true
            detail.itemJSON = self.itemsJSON[selectedIndex!]
            detail.userJSON = self.userJSON
            detail.loadData()
        }
    }
}
