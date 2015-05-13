//
//  OffersDetailController.swift
//  ChangeIt
//
//  Created by i818292 on 5/7/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class OffersDetailController: UITableViewController {
    var offerJSON:JSON!

    @IBOutlet var itemImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = offerJSON["src"]["title"].string
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(offerJSON["src"]["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.itemImageView.image = UIImage(data: imageData!)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("offerFrom", forIndexPath: indexPath) as! UITableViewCell

        // display src item information
        PFQuery(className:"Image").getObjectInBackgroundWithId(offerJSON["dst"]["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            (cell.viewWithTag(101) as! UIImageView).image = UIImage(data: imageData!)
        })
        
        let title = cell.viewWithTag(102) as! UILabel
        title.text = offerJSON["dst"]["title"].string
        
        let user = PFCloud.callFunction("getUserOfItem", withParameters: ["itemId":(offerJSON["dst"]["objectId"].string)!])
        let userJSON = JSON(data:(user as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        let name = cell.viewWithTag(103) as! UILabel
        name.text = userJSON[0]["name"].string
        
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tableView = self.view as! UITableView
        let itemJSON = offerJSON["dst"]
        
        // get user info based on item
        let user = PFCloud.callFunction("getUserOfItem", withParameters: ["itemId":(itemJSON["objectId"].string)!])
        let userJSON = JSON(data:(user as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let detail = segue.destinationViewController as! OfferDetailController
        detail.userJSON = userJSON[0]
        detail.itemJSON = itemJSON
        detail.otherItemJSON = offerJSON["src"]
    }
}
