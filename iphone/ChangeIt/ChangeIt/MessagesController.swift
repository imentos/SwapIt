//
//  MessagesController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 7/12/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class MessagesController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var itemDetailButton: UIButton!
    @IBOutlet weak var dockHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    var questionJSON:JSON!
    var repliesJSON:JSON = nil
    var userJSON:JSON = nil
    var itemJSON:JSON!
    var fromUser:Bool! = false
    
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        print("cancel")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendButton.enabled = false
        
        createImageQuery().getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.itemDetailButton.setTitle("", forState: .Normal)
            self.itemDetailButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
            self.itemDetailButton.setImage(UIImage(data: imageData!), forState: UIControlState.Normal)
        })
        
        displayUserPhoto(self.userPhoto, userJSON: self.userJSON)

        self.userNameLabel.text = self.userJSON["name"].string
        
        // Do any additional setup after loading the view.
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        
        let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableTapped")
        self.messageTableView.addGestureRecognizer(tapRecognizer)

        //self.messageTextField.becomeFirstResponder()
        self.messageTextField.autocorrectionType = UITextAutocorrectionType.No
        self.messageTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollDown()
        
        if let _ = questionJSON {
            PFCloud.callFunctionInBackground("setQuestionRead", withParameters: ["objectId": self.questionJSON["objectId"].string!], block:{
                (results:AnyObject?, error: NSError?) -> Void in
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableTapped() {
        self.messageTextField.endEditing(true)
    }
    
    @IBAction func clickItemImage(sender: AnyObject) {
        performSegueWithIdentifier(fromUser == true ? "itemDetail" : "cancel", sender: self)
    }
    
    func sendNewReplyNotification(qid:String) {
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: PFUser(withoutDataWithObjectId: self.userJSON["objectId"].string!))
        let push = PFPush()
        let item = self.itemJSON["title"].string!
        let alert = "You got a new message for your item \"\(item)\""
        push.setQuery(pushQuery)
        push.setData(["alert": alert, "type": "reply", "from": (PFUser.currentUser()?.objectId)!, "to": self.userJSON["objectId"].string!, "qid": qid])
        push.sendPushInBackgroundWithBlock({ (result, error) -> Void in
            if let _ = error {
                print(error)
            }
        })
    }
    
    // this will go to receiver's my items
    func sendNewQuestionNotification(qid:String) {
        let pushQuery = PFInstallation.query()
        pushQuery!.whereKey("user", equalTo: PFUser(withoutDataWithObjectId: self.userJSON["objectId"].string!))
        let push = PFPush()
        let item = self.itemJSON["title"].string!
        let alert = "You got a new message for your item \"\(item)\""
        push.setQuery(pushQuery)
        push.setData(["alert": alert, "type": "message", "from": (PFUser.currentUser()?.objectId)!, "to": self.userJSON["objectId"].string!, "qid": qid])
        push.sendPushInBackgroundWithBlock({ (result, error) -> Void in
            if let _ = error {
                print(error)
            }
        })
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        if let _ = questionJSON {
            let uuid = NSUUID().UUIDString
            PFCloud.callFunctionInBackground("addReplyToQuestion", withParameters: ["text": self.messageTextField.text!, "objectId": uuid, "questionId": (questionJSON["objectId"].string)!, "userId": (PFUser.currentUser()?.objectId)!], block:{
                (items:AnyObject?, error: NSError?) -> Void in
                
                self.sendNewReplyNotification((self.questionJSON["objectId"].string)!)
                
                PFCloud.callFunctionInBackground("setQuestionUnread", withParameters: ["objectId": self.questionJSON["objectId"].string!], block:{
                    (results:AnyObject?, error: NSError?) -> Void in
                })
                
                self.loadData()
            })
        
        } else {
            let uuid = NSUUID().UUIDString
            PFCloud.callFunctionInBackground("addQuestion", withParameters: ["text": self.messageTextField.text!, "objectId": uuid, "owner": (PFUser.currentUser()?.objectId)!], block:{
                (result:AnyObject?, error: NSError?) -> Void in
                self.questionJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)[0]
                let itemId = self.itemJSON["objectId"].string
                PFCloud.callFunctionInBackground("askItemQuestionByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": itemId!, "questionId": uuid], block:{
                    (items:AnyObject?, error: NSError?) -> Void in
                    self.loadData()
                    
                    self.sendNewQuestionNotification(uuid)
                })
            })
        }
    }
    
    func scrollDown() {
        if (messageTableView.contentSize.height > messageTableView.frame.size.height) {
            let offset = CGPointMake(0, messageTableView.contentSize.height - messageTableView.frame.size.height);
            self.messageTableView.setContentOffset(offset, animated: true)
        }
    }
    
    @IBAction func valueChange(sender: AnyObject) {
        self.sendButton.enabled = self.messageTextField.text!.isEmpty == false
    }
    
    @IBAction func endEditing(sender: AnyObject) {
        self.view.layoutIfNeeded()
        self.dockHeightConstraint.constant = 50
    }
    
    @IBAction func startEditing(sender: AnyObject) {
        self.view.layoutIfNeeded()
        self.dockHeightConstraint.constant = 210

        self.loadData()
    }
    
    func loadData() {
        if let _ = questionJSON {
            PFCloud.callFunctionInBackground("getRepliesOfQuestion", withParameters: ["questionId":(questionJSON["objectId"].string)!], block: {
                (replies:AnyObject?, error: NSError?) -> Void in
                self.repliesJSON = JSON(data:(replies as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                self.messageTableView.reloadData()
                self.messageTextField.text = ""

                self.scrollDown()
            })
        }
    }
    
    func timestampToText(ts:Double)->String {
        let timestampAsDouble = NSTimeInterval(ts) / 1000.0
        let date = NSDate(timeIntervalSince1970:timestampAsDouble)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(date)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.messageTableView.dequeueReusableCellWithIdentifier("message") as? PTSMessagingCell
        if let _ = cell {
        } else {
            cell = PTSMessagingCell(messagingCellWithReuseIdentifier: "message")
        }
        
        if (indexPath.row == 0) {
            let isOwner:Bool = self.questionJSON["owner"].string == PFUser.currentUser()?.objectId
            let text = self.questionJSON["text"].string
            let time = timestampToText(self.questionJSON["timestamp"].double!)
            
            cell!.messageLabel.text = text
            cell!.messageLabel.textColor = isOwner ? UIColor.whiteColor() : UIColor.blackColor()
            cell!.timeLabel.text = time
            cell!.sent = isOwner
            
        } else {
            let isOwner:Bool = self.repliesJSON[indexPath.row - 1]["owner"].string == PFUser.currentUser()?.objectId
            let text = self.repliesJSON[indexPath.row - 1]["text"].string
            let time = timestampToText(self.repliesJSON[indexPath.row - 1]["timestamp"].double!)
            
            cell!.messageLabel.text = text
            cell!.messageLabel.textColor = isOwner ? UIColor.whiteColor() : UIColor.blackColor()
            cell!.timeLabel.text = time
            cell?.sent = isOwner
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = questionJSON {
            return self.repliesJSON.count + 1
        } else {
            return 0
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "itemDetail") {
            let detail = segue.destinationViewController as! ItemDetailController
            //navi.toolbarHidden = true
            detail.userJSON = userJSON
            detail.itemJSON = itemJSON
        }
    }
}
