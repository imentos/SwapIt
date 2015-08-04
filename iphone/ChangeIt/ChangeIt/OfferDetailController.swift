//
//  OfferDetailController.swift
//  ChangeIt
//
//  Created by i818292 on 5/7/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class OfferDetailController: UITableViewController {
    var itemJSON:JSON!
    var userJSON:JSON!
    var otherItemJSON:JSON!

    @IBOutlet var itemDescription: UITextView!
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var itemImageView: UIImageView!    
    @IBOutlet var otherItemImageView: UIImageView!
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        println("cancel")
    }

    @IBAction func sendQuestion(segue:UIStoryboardSegue) {
        let view = segue.sourceViewController as! AddQuestionController
        let uuid = NSUUID().UUIDString
        
        PFCloud.callFunctionInBackground("addQuestion", withParameters: ["text": view.questionTextView.text, "objectId": uuid], block:{
            (items:AnyObject?, error: NSError?) -> Void in
            let itemId = self.itemJSON["objectId"].string
            PFCloud.callFunctionInBackground("askItemQuestionByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": itemId!, "questionId": uuid], block:{
                (items:AnyObject?, error: NSError?) -> Void in
            })
        })
    }
    
    func tapDetected() {
        performSegueWithIdentifier("itemDetail", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapDetected"))
        singleTap.numberOfTapsRequired = 1
        otherItemImageView.userInteractionEnabled = true
        otherItemImageView.addGestureRecognizer(singleTap)


        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.itemImageView.image = UIImage(data: imageData!)
        })
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(otherItemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.otherItemImageView.image = UIImage(data: imageData!)
        })

        self.title = itemJSON["title"].string
        self.itemDescription.text = itemJSON["description"].string
        self.userLabel.text = userJSON["name"].string
        
        PFCloud.callFunctionInBackground("setExchangeRead", withParameters: ["objectId": itemJSON["objectId"].string!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "askQuestion") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.topViewController as! AddQuestionController
            view.userJSON = self.userJSON
            view.itemImage = self.itemImageView.image!
            
        } else if (segue.identifier == "itemDetail") {
            
            PFCloud.callFunctionInBackground("getUserOfItem", withParameters: ["itemId":(otherItemJSON["objectId"].string)!], block:{
                (user:AnyObject?, error: NSError?) -> Void in
                let userJSON = JSON(data:(user as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                
                let detail = segue.destinationViewController as! ItemDetailController
                //let detail = navi.topViewController as! ItemDetailController
                detail.userJSON = userJSON[0]
                detail.itemJSON = self.otherItemJSON
                
                detail.loadData(true)
            });
        }
    }

}
