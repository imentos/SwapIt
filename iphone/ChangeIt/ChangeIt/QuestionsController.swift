//
//  QuestionSentController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 6/27/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class QuestionsController: UITableViewController, UIActionSheetDelegate {
    var questionsJSON:JSON = nil

    @IBAction func cancel(segue:UIStoryboardSegue) {
    }
    
    func loadData() {
        PFCloud.callFunctionInBackground("getAskedQuestions", withParameters: ["userId":(PFUser.currentUser()?.objectId)!], block: {
            (questions:AnyObject?, error: NSError?) -> Void in
            self.questionsJSON = JSON(data:(questions as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
        })
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            let actionSheet = UIActionSheet(title: "Are you sure you want to delete this question?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "OK")
            actionSheet.tag = indexPath.row
            actionSheet.showInView(self.view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            let questionJSON = questionsJSON[actionSheet.tag]
            PFCloud.callFunctionInBackground("deleteQuestion", withParameters: ["questionId": (questionJSON["question"]["objectId"].string)!], block: {
                (result:AnyObject?, error: NSError?) -> Void in
                self.loadData()
            })
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (questionsJSON == nil) {
            return 0
        }
        return questionsJSON.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("question", forIndexPath: indexPath) as! UITableViewCell
        
        let itemTitle = cell.viewWithTag(102) as! UILabel
        itemTitle.text = questionsJSON[indexPath.row]["item"]["title"].string
        
        let question = cell.viewWithTag(103) as! UILabel
        question.text = questionsJSON[indexPath.row]["question"]["text"].string
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(questionsJSON[indexPath.row]["item"]["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            let imageView = cell.viewWithTag(101) as! UIImageView
            imageView.image = UIImage(data: imageData!)
        })

        return cell
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier != "messages") {
            return
        }
        
        let index = tableView.indexPathForSelectedRow()?.row
        let messages = segue.destinationViewController as! MessagesController
        messages.fromUser = true
        messages.title = questionsJSON[index!]["item"]["title"].string
        messages.questionJSON = questionsJSON[index!]["question"]
        messages.userJSON = questionsJSON[index!]["user"]
        messages.itemJSON = questionsJSON[index!]["item"]
        messages.loadData()
    }

}
