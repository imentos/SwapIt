//
//  MyItemDetailController.swift
//  ChangeIt
//
//  Created by i818292 on 5/19/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class MyItemDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var questionsJSON:JSON = nil
    var offeredItemsJSON:JSON = nil
    var itemId:String = ""
    var itemImageId:String = ""
    
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var detailTable: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBAction func indexChanged(sender: AnyObject) {
        self.detailTable.reloadData()
    }
    
    @IBOutlet var testLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadData() {
        PFCloud.callFunctionInBackground("getQuestionedItemsByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            self.questionsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.segmentedControl.setTitle(String(format:"Messages (%d)", self.questionsJSON.count), forSegmentAtIndex: 1)
        })

        PFCloud.callFunctionInBackground("getOfferedItemsByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId":itemId], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            if (results == nil) {
                self.offeredItemsJSON = JSON([])
                return
            }
            self.offeredItemsJSON = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.detailTable.reloadData()
            self.segmentedControl.setTitle(String(format:"Offers Received (%d)", self.offeredItemsJSON.count), forSegmentAtIndex: 0)
        })
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(itemImageId, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.itemImageView.image = UIImage(data: imageData!)
        })

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (segmentedControl.selectedSegmentIndex == 0) {
            self.performSegueWithIdentifier("offer", sender: self)
        } else {
            self.performSegueWithIdentifier("question", sender: self)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (segmentedControl.selectedSegmentIndex == 0) {
            if (offeredItemsJSON == nil) {
                return 0
            }
            return offeredItemsJSON.count
        } else {
            if (questionsJSON == nil) {
                return 0
            }
            return questionsJSON.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myItemDetail", forIndexPath: indexPath) as! UITableViewCell
        let photo = cell.viewWithTag(101) as! UIImageView
        let title = cell.viewWithTag(102) as! UILabel
        let name = cell.viewWithTag(103) as! UILabel
        let readIcon = cell.viewWithTag(104) as! UIImageView
        
        if (segmentedControl.selectedSegmentIndex == 0) {
            let offeredItemJSON = offeredItemsJSON[indexPath.row]
            
            PFQuery(className:"Image").getObjectInBackgroundWithId(offeredItemJSON["item"]["photo"].string!, block: {
                (imageObj:PFObject?, error: NSError?) -> Void in
                let imageData = (imageObj!["file"] as! PFFile).getData()
                photo.image = UIImage(data: imageData!)
            })
            title.text = offeredItemJSON["item"]["title"].string
            name.text = offeredItemJSON["user"]["name"].string
            cell.backgroundColor = UIColor(red:0.851, green:0.047, blue:0.314, alpha:0.2)
            //readIcon.hidden = offeredItemJSON["exchange"]["read"].bool!

        } else {
            let questionJSON = questionsJSON[indexPath.row]
            
            photo.image = UIImage(named: "bottom_User_Inactive")
            title.text = questionJSON["question"]["text"].string
            name.text = questionJSON["user"]["name"].string
            cell.backgroundColor = UIColor(red:0.851, green:0.047, blue:0.314, alpha:0.2)
            //readIcon.hidden = questionJSON["link"]["read"].bool!
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "back") {
            return;
        }
        let indexPath = detailTable.indexPathForSelectedRow()
        let index = indexPath!.row
        let cell = detailTable.cellForRowAtIndexPath(indexPath!)
        var readIcon = cell!.viewWithTag(104) as! UIImageView

        if (segue.identifier == "offer") {
            let offeredItemJSON = offeredItemsJSON[index]
            
            let detail = segue.destinationViewController as! OfferDetailController
            detail.itemJSON = offeredItemJSON["item"]
            detail.otherItemJSON = offeredItemJSON["otherItem"]
            detail.userJSON = offeredItemJSON["user"]
            //readIcon.hidden = true
            
        } else if (segue.identifier == "question") {
            let questionJSON = self.questionsJSON[index]
            
            let question = segue.destinationViewController as! QuestionController
            question.questionJSON = questionJSON
            //readIcon.hidden = true
        }
        
        cell?.backgroundColor = UIColor.clearColor()
    }
}
