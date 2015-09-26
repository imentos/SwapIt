//
//  QuestionController.swift
//  ChangeIt
//
//  Created by i818292 on 5/20/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class QuestionController: UITableViewController {

    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet var questionTextView: UITextView!
    @IBOutlet var userNameLabel: UILabel!
    
    var questionJSON:JSON = nil
    
    @IBAction func reply(sender: AnyObject) {
        let uuid = NSUUID().UUIDString
        let qId = questionJSON["question"]["objectId"].string
        PFCloud.callFunctionInBackground("addReplyToQuestion", withParameters: ["text": "bg", "objectId": uuid, "questionId": qId!], block:{
            (items:AnyObject?, error: NSError?) -> Void in
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questionTextView.text = questionJSON["question"]["text"].string
        self.userNameLabel.text = questionJSON["user"]["name"].string
        
        self.userPhoto.layer.borderWidth = 1
        self.userPhoto.layer.masksToBounds = true
        self.userPhoto.layer.borderColor = UIColor.blackColor().CGColor
        self.userPhoto.layer.cornerRadius = self.userPhoto.bounds.height / 2
        if let data = NSData(contentsOfURL: NSURL(string: String(format:"https://graph.facebook.com/%@/picture?width=120&height=120", questionJSON["user"]["facebookId"].string!))!) {
            self.userPhoto.image = UIImage(data: data)
        }

        let timestampAsDouble = NSTimeInterval(questionJSON["question"]["timestamp"].double!) / 1000.0
        var date = NSDate(timeIntervalSince1970:timestampAsDouble)
        var dateFormatter = NSDateFormatter()
        //dateFormatter.dateFormat = "yyyy.MM.dd"//"EEE, MMM d, 'yy"
        dateFormatter.dateStyle = .FullStyle
        self.timestamp.text = dateFormatter.stringFromDate(date)
        
        PFCloud.callFunctionInBackground("setQuestionRead", withParameters: ["objectId": questionJSON["question"]["objectId"].string!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
