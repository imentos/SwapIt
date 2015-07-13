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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let left = cell.viewWithTag(100) as! UILabel
        let right = cell.viewWithTag(101) as! UILabel
        if (indexPath.row == 0) {
            left.text = self.questionJSON["text"].string
            right.text = ""
        } else {
            let isOwner:Bool = self.repliesJSON[indexPath.row - 1]["owner"].string == PFUser.currentUser()?.objectId
            if (isOwner) {
                left.text = ""
                right.text = self.repliesJSON[indexPath.row - 1]["text"].string
            } else {
                left.text = self.repliesJSON[indexPath.row - 1]["text"].string
                right.text = ""                
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
