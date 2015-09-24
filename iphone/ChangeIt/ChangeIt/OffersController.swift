//
//  SentOfferController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 5/6/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class OffersController: UITableViewController {
    var offersJSON:JSON = nil
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadData() {
        PFCloud.callFunctionInBackground("getSentOffersByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!], block:{
            (offers:AnyObject?, error: NSError?) -> Void in
            self.offersJSON = JSON(data:(offers as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (offersJSON == nil) {
            return 0
        }
        return offersJSON.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("offer", forIndexPath: indexPath) as! UITableViewCell
        let offerJSON = offersJSON[indexPath.row]
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(offerJSON["src"]["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            (cell.viewWithTag(101) as! UIImageView).image = UIImage(data: imageData!)
        })
        
        let label = cell.viewWithTag(102) as! UILabel
        label.text = offerJSON["src"]["title"].string
        
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "offerDetail") {
            let tableView = self.view as! UITableView
            let offerJSON = offersJSON[(tableView.indexPathForSelectedRow()?.row)!]
            
            let navi = segue.destinationViewController as! UINavigationController
            let details = navi.topViewController as! OffersDetailController
            details.offerJSON = offerJSON
        }
    }
}
