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

    @IBOutlet var scrollView: UIScrollView!
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
        
        self.messageTableView.rowHeight = UITableViewAutomaticDimension;
        self.messageTableView.estimatedRowHeight = 40.0; // set to whatever your "average" cell height is
        
        let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableTapped")
        self.messageTableView.addGestureRecognizer(tapRecognizer)

        //self.messageTextField.becomeFirstResponder()
        self.messageTextField.autocorrectionType = UITextAutocorrectionType.No
        self.messageTextField.delegate = self
    }

    private func startKeyboardObserver(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func stopKeyboardObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.stopKeyboardObserver()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.startKeyboardObserver()

        self.loadData()
        
        scrollDown()
        
        if let _ = questionJSON {
            PFCloud.callFunctionInBackground("setQuestionRead", withParameters: ["objectId": self.questionJSON["objectId"].string!], block:{
                (results:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    return
                }
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
            let spinner = createSpinner(self.view)
            PFCloud.callFunctionInBackground("addReplyToQuestion", withParameters: ["text": self.messageTextField.text!, "objectId": uuid, "questionId": (questionJSON["objectId"].string)!, "userId": (PFUser.currentUser()?.objectId)!], block:{
                (items:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    spinner.stopAnimating()
                    return
                }
                
                self.sendNewReplyNotification((self.questionJSON["objectId"].string)!)
                
                PFCloud.callFunctionInBackground("setQuestionUnread", withParameters: ["objectId": self.questionJSON["objectId"].string!], block:{
                    (results:AnyObject?, error: NSError?) -> Void in
                    if let error = error {
                        NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                        spinner.stopAnimating()
                        return
                    }
                })
                
                self.loadData()
                
                spinner.stopAnimating()
            })
        
        } else {
            let uuid = NSUUID().UUIDString
            let spinner = createSpinner(self.view)
            PFCloud.callFunctionInBackground("addQuestion", withParameters: ["text": self.messageTextField.text!, "objectId": uuid, "owner": (PFUser.currentUser()?.objectId)!], block:{
                (result:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    spinner.stopAnimating()
                    return
                }
                self.questionJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)[0]
                let itemId = self.itemJSON["objectId"].string
                PFCloud.callFunctionInBackground("askItemQuestionByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": itemId!, "questionId": uuid], block:{
                    (items:AnyObject?, error: NSError?) -> Void in
                    if let error = error {
                        NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                        spinner.stopAnimating()
                        return
                    }
                    self.loadData()
                    
                    self.sendNewQuestionNotification(uuid)
                    
                    spinner.stopAnimating()
                })
            })
        }
    }
    
    func scrollDown() {
        let adjustHeight:CGFloat = 250
        if (messageTableView.contentSize.height > messageTableView.frame.size.height - adjustHeight) {
            let offset = CGPointMake(0, messageTableView.contentSize.height - self.messageTableView.frame.size.height + adjustHeight);
            self.messageTableView.setContentOffset(offset, animated: true)
        }
    }
    
    @IBAction func valueChange(sender: AnyObject) {
        self.sendButton.enabled = self.messageTextField.text!.isEmpty == false
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                let offsetKeyboard:CGFloat = 60
                let contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - offsetKeyboard,  0.0);
                
                self.scrollView.contentInset = contentInset
                self.scrollView.scrollIndicatorInsets = contentInset
                
                self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, 0 + keyboardSize.height - offsetKeyboard)
                
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let _: CGSize =  userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                let contentInset = UIEdgeInsetsZero;
                self.scrollView.contentInset = contentInset
                self.scrollView.scrollIndicatorInsets = contentInset
                self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y)
            }
        }
    }
    
    func loadData() {
        if let _ = questionJSON {
            let spinner = createSpinner(self.view)
            PFCloud.callFunctionInBackground("getRepliesOfQuestion", withParameters: ["questionId":(questionJSON["objectId"].string)!], block: {
                (replies:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    spinner.stopAnimating()
                    return
                }
                self.repliesJSON = JSON(data:(replies as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                self.messageTableView.reloadData()
                self.messageTextField.text = ""

                self.scrollDown()
                spinner.stopAnimating()
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
        let cell:UITableViewCell = self.messageTableView.dequeueReusableCellWithIdentifier("message")!
        let leftLabel = cell.viewWithTag(101) as! UILabel
        let leftTimeLabel = cell.viewWithTag(102) as! UILabel
        leftTimeLabel.font = UIFont(name: "Geogrotesque-Regular", size: 12)
        
        let rightLabel = cell.viewWithTag(201) as! UILabel
        rightLabel.textColor = UIColor.whiteColor()
        let rightTimeLabel = cell.viewWithTag(202) as! UILabel
        rightTimeLabel.font = UIFont(name: "Geogrotesque-Regular", size: 12)

        if (indexPath.row == 0) {
            let isOwner:Bool = self.questionJSON["owner"].string == PFUser.currentUser()?.objectId
            let text = self.questionJSON["text"].string
            let time = timestampToText(self.questionJSON["timestamp"].double!)
            
            rightLabel.text = isOwner ? text : ""
            rightTimeLabel.text = isOwner ? time : ""
            
            leftLabel.text = isOwner ? "" : text
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
            detail.loadData()
        }
    }
}
