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
        println("cancel")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendButton.enabled = false
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.itemDetailButton.setTitle("", forState: .Normal)
            self.itemDetailButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
            self.itemDetailButton.setImage(UIImage(data: imageData!), forState: UIControlState.Normal)
        })
        
        displayUserPhoto(self.userPhoto, self.userJSON)

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
        scrollDown()
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
    
    @IBAction func sendMessage(sender: UIButton) {
        if let q = questionJSON {
            let uuid = NSUUID().UUIDString
            PFCloud.callFunctionInBackground("addReplyToQuestion", withParameters: ["text": self.messageTextField.text, "objectId": uuid, "questionId": (questionJSON["objectId"].string)!, "userId": (PFUser.currentUser()?.objectId)!], block:{
                (items:AnyObject?, error: NSError?) -> Void in
                self.loadData()
            })
        
        } else {
            let uuid = NSUUID().UUIDString
            PFCloud.callFunctionInBackground("addQuestion", withParameters: ["text": self.messageTextField.text, "objectId": uuid, "owner": (PFUser.currentUser()?.objectId)!], block:{
                (result:AnyObject?, error: NSError?) -> Void in
                self.questionJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)[0]
                let itemId = self.itemJSON["objectId"].string
                PFCloud.callFunctionInBackground("askItemQuestionByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": itemId!, "questionId": uuid], block:{
                    (items:AnyObject?, error: NSError?) -> Void in
                    self.loadData()
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
        self.sendButton.enabled = self.messageTextField.text.isEmpty == false
    }
    
    @IBAction func endEditing(sender: AnyObject) {
        self.view.layoutIfNeeded()
        self.dockHeightConstraint.constant = 50
    }
    
    @IBAction func startEditing(sender: AnyObject) {
        self.view.layoutIfNeeded()
        self.dockHeightConstraint.constant = 270

        self.loadData()
    }
    
    func loadData() {
        if let q = questionJSON {
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
        var date = NSDate(timeIntervalSince1970:timestampAsDouble)
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(date)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.messageTableView.dequeueReusableCellWithIdentifier("message") as! UITableViewCell
        let leftLabel = cell.viewWithTag(100) as! UILabel
        let rightLabel = cell.viewWithTag(101) as! UILabel
        let leftTimeLabel = cell.viewWithTag(200) as! UILabel
        let rightTimeLabel = cell.viewWithTag(201) as! UILabel
        
        if (indexPath.row == 0) {
            let time = timestampToText(self.questionJSON["timestamp"].double!)
            let isOwner:Bool = self.questionJSON["owner"].string == PFUser.currentUser()?.objectId
            
            rightLabel.text = isOwner ? self.questionJSON["text"].string : ""
            rightTimeLabel.text = isOwner ? time : ""
                
            leftLabel.text = isOwner ? "" : self.questionJSON["text"].string
            leftTimeLabel.text = isOwner ? "" : time
        } else {
            let isOwner:Bool = self.repliesJSON[indexPath.row - 1]["owner"].string == PFUser.currentUser()?.objectId
            let text = self.repliesJSON[indexPath.row - 1]["text"].string
            let time = timestampToText(self.repliesJSON[indexPath.row - 1]["timestamp"].double!)

            if (isOwner) {
                leftLabel.hidden = true
                leftTimeLabel.hidden = true
                rightLabel.hidden = false
                rightTimeLabel.hidden = false
                
                rightLabel.text = text
                rightTimeLabel.text = time
            } else {
                leftLabel.hidden = false
                leftTimeLabel.hidden = false
                rightLabel.hidden = true
                rightTimeLabel.hidden = true

                leftLabel.text = text
                leftTimeLabel.text = time
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let q = questionJSON {
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
            detail.loadData(false)
        }
    }
}
