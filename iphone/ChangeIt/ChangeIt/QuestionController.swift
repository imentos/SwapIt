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
        
        displayUserPhoto(self.userPhoto, userJSON: self.questionJSON["user"])

        let timestampAsDouble = NSTimeInterval(questionJSON["question"]["timestamp"].double!) / 1000.0
        let date = NSDate(timeIntervalSince1970:timestampAsDouble)
        let dateFormatter = NSDateFormatter()
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
