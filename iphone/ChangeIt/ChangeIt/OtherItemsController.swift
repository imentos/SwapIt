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
        println("cancel")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.userName.text = self.userJSON["name"].string!
        
        self.userPhoto.layer.borderWidth = 1
        self.userPhoto.layer.masksToBounds = true
        self.userPhoto.layer.borderColor = UIColor.blackColor().CGColor
        self.userPhoto.layer.cornerRadius = self.userPhoto.bounds.height / 2
        if (self.userJSON["photo"] == nil) {
            if (PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!)) {
                if let image = NSData(contentsOfURL: NSURL(string: String(format:"https://graph.facebook.com/%@/picture?width=160&height=160", self.userJSON["facebookId"].string!))!) {
                    self.userPhoto.image = UIImage(data: image)
                }
            } else {
                self.userPhoto.image = UIImage(named: "bottom_User_Inactive")
            }
        } else {
            PFQuery(className:"Image").getObjectInBackgroundWithId(self.userJSON["photo"].string!, block: {
                (imageObj:PFObject?, error: NSError?) -> Void in
                let imageData = (imageObj!["file"] as! PFFile).getData()
                self.userPhoto.image = UIImage(data: imageData!)
            })
        }
    }
    
    func loadData() {
        let userId = self.userJSON["objectId"].string!
        PFCloud.callFunctionInBackground("getItemsByUser", withParameters: ["userId": userId], block: {
            (items:AnyObject?, error: NSError?) -> Void in
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.itemCount.text = "\(self.itemsJSON.count)"
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
//        self.title = offerJSON["src"]["title"].string
        
//        PFQuery(className:"Image").getObjectInBackgroundWithId(userJSON["photo"].string!, block: {
//            (imageObj:PFObject?, error: NSError?) -> Void in
//            let imageData = (imageObj!["file"] as! PFFile).getData()
//            self.itemImageView.image = UIImage(data: imageData!)
//        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let x = itemsJSON {
            return itemsJSON.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath) as! UITableViewCell
        let itemJSON = itemsJSON[indexPath.row]
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            let imageView = cell.viewWithTag(101) as! UIImageView
            imageView.image = UIImage(data: imageData!)
        })
        
        let label = cell.viewWithTag(102) as! UILabel
        label.text = itemJSON["title"].string
        
//        PFCloud.callFunctionInBackground("getReceivedCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
//            (result:AnyObject?, error: NSError?) -> Void in
//            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//            let offersCountLabel = cell.viewWithTag(103) as! UILabel
//            offersCountLabel.text = "/ \(countJSON[0].int!)"
//        })
//        
//        PFCloud.callFunctionInBackground("getExchangesCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
//            (result:AnyObject?, error: NSError?) -> Void in
//            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//            let offersCountLabel = cell.viewWithTag(104) as! UILabel
//            offersCountLabel.text = "\(countJSON[0].int!)"
//        })
//        
//        PFCloud.callFunctionInBackground("getQuestionsCountOfItem", withParameters: ["itemId": (itemJSON["objectId"].string)!], block: {
//            (result:AnyObject?, error: NSError?) -> Void in
//            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//            let questionsCountLabel = cell.viewWithTag(105) as! UILabel
//            questionsCountLabel.text = "/ \(countJSON[0].int!)"
//        })
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "detail") {
            let selectedIndex = self.tableView.indexPathForSelectedRow()?.row
            
            let detail = segue.destinationViewController as! ItemDetailController
            detail.fromOffer = true
            detail.itemJSON = self.itemsJSON[selectedIndex!]
            detail.userJSON = self.userJSON
            detail.loadData(false)
        }
    }
}
