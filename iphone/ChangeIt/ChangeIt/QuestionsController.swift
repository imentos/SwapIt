//
//  QuestionSentController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 6/27/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class QuestionsController: UITableViewController {
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("itemDetail", sender: tableView)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
        if (segue.identifier != "itemDetail") {
            return
        }
        let itemJSON = questionsJSON[(tableView.indexPathForSelectedRow()?.row)!]["item"]
        
        // get user info based on item
        PFCloud.callFunctionInBackground("getUserOfItem", withParameters: ["itemId":(itemJSON["objectId"].string)!], block:{
            (user:AnyObject?, error: NSError?) -> Void in
            let userJSON = JSON(data:(user as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            let navi = segue.destinationViewController as! UINavigationController
            let detail = navi.childViewControllers[0] as! ItemDetailController
            detail.userJSON = userJSON[0]
            detail.itemJSON = itemJSON
            detail.toolbarItems?.removeAll(keepCapacity: false)
            detail.navigationItem.rightBarButtonItem = nil
            detail.loadData()
        })
    }

}
