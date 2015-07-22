//
//  MessagesController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 7/12/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class MessagesController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dockHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    var questionJSON:JSON = nil
    var repliesJSON:JSON = nil
    var userJSON:JSON = nil
    var itemJSON:JSON = nil
    
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var itemPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userPhoto.layer.borderWidth = 1
        self.userPhoto.layer.masksToBounds = true
        self.userPhoto.layer.borderColor = UIColor.blackColor().CGColor
        self.userPhoto.layer.cornerRadius = self.userPhoto.bounds.height / 2
        self.userPhoto.image = UIImage(data: NSData(contentsOfURL: NSURL(string: String(format:"https://graph.facebook.com/%@/picture?width=80&height=80", self.userJSON["facebookId"].string!))!)!)

        self.userNameLabel.text = self.userJSON["name"].string
        
        // Do any additional setup after loading the view.
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        
        let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableTapped")
        self.messageTableView.addGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableTapped() {
        self.messageTextField.endEditing(true)
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        let uuid = NSUUID().UUIDString
        PFCloud.callFunctionInBackground("addReplyToQuestion", withParameters: ["text": self.messageTextField.text, "objectId": uuid, "questionId": (questionJSON["objectId"].string)!, "userId": (PFUser.currentUser()?.objectId)!], block:{
            (items:AnyObject?, error: NSError?) -> Void in
            self.messageTextField.text = ""
            self.messageTextField.endEditing(true)
            self.loadData()
        })
    }
    
    @IBAction func endEditing(sender: AnyObject) {
        self.view.layoutIfNeeded()
        self.dockHeightConstraint.constant = 50
    }
    
    @IBAction func startEditing(sender: AnyObject) {
        self.view.layoutIfNeeded()
        self.dockHeightConstraint.constant = 310
    }
    
    func loadData() {
        
        PFCloud.callFunctionInBackground("getRepliesOfQuestion", withParameters: ["questionId":(questionJSON["objectId"].string)!], block: {
            (replies:AnyObject?, error: NSError?) -> Void in
            self.repliesJSON = JSON(data:(replies as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if (self.repliesJSON.count == 0) {
                return
            }
            self.messageTableView.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.messageTableView.dequeueReusableCellWithIdentifier("message") as! UITableViewCell
        let leftLabel = cell.viewWithTag(100) as! UILabel
        let rightLabel = cell.viewWithTag(101) as! UILabel
        let leftTimeLabel = cell.viewWithTag(200) as! UILabel
        let rightTimeLabel = cell.viewWithTag(201) as! UILabel
        
        if (indexPath.row == 0) {
            leftLabel.text = self.questionJSON["text"].string
            leftTimeLabel.text = self.questionJSON["timestamp"].string
                
            rightLabel.text = ""
            rightTimeLabel.text = ""
        } else {
            let isOwner:Bool = self.repliesJSON[indexPath.row - 1]["owner"].string == PFUser.currentUser()?.objectId
            let text = self.repliesJSON[indexPath.row - 1]["text"].string
 
            let timestampAsDouble = NSTimeInterval(self.repliesJSON[indexPath.row - 1]["timestamp"].double!) / 1000.0
            var date = NSDate(timeIntervalSince1970:timestampAsDouble)
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            let time = dateFormatter.stringFromDate(date)

//            let timestampAsDouble = NSTimeInterval(questionJSON["question"]["timestamp"].double!) / 1000.0
//            var date = NSDate(timeIntervalSince1970:timestampAsDouble)
//            var dateFormatter = NSDateFormatter()
//            //dateFormatter.dateFormat = "yyyy.MM.dd"//"EEE, MMM d, 'yy"
//            dateFormatter.dateStyle = .FullStyle
//            self.timestamp.text = dateFormatter.stringFromDate(date)
//            let time = self.repliesJSON[indexPath.row - 1]["timestamp"].string
            
            if (isOwner) {
                leftLabel.text = ""
                leftTimeLabel.text = ""
                
                rightLabel.text = text
                rightTimeLabel.text = time
            } else {
                leftLabel.text = text
                leftTimeLabel.text = time
                
                rightLabel.text = ""
                rightTimeLabel.text = ""
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repliesJSON.count + 1
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
