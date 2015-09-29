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
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        println("cancel")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offerJSON["src"]["dst"].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("offerFrom", forIndexPath: indexPath) as! UITableViewCell
        
        let dstJSON = offerJSON["src"]["dst"][indexPath.row]

        // display src item information
        PFQuery(className:"Image").getObjectInBackgroundWithId(dstJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            (cell.viewWithTag(101) as! UIImageView).image = UIImage(data: imageData!)
        })
        
        let title = cell.viewWithTag(102) as! UILabel
        title.text = dstJSON["title"].string
        
        PFCloud.callFunctionInBackground("getUserOfItem", withParameters: ["itemId":(dstJSON["objectId"].string)!], block: {
            (results:AnyObject?, error: NSError?) -> Void in
            let userJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let name = cell.viewWithTag(103) as! UILabel
            name.text = userJSON[0]["name"].string
        })
        
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "itemDetail") {
            let selectedIndex = self.tableView.indexPathForSelectedRow()?.row
            
            let detail = segue.destinationViewController as! ItemDetailController
            detail.fromOffer = true
            detail.itemJSON = offerJSON["src"]["dst"][selectedIndex!]
            detail.userJSON = offerJSON["src"]["otherUser"][selectedIndex!]
            detail.loadData(false)
        }
    }
}
