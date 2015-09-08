//
//  QuestionController.swift
//  ChangeIt
//
//  Created by i818292 on 5/18/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit

class AddQuestionController: UITableViewController {

    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var questionTextView: UITextView!
    @IBOutlet weak var userPhoto: UIImageView!
    
    var itemImage:UIImage? = nil
    var userJSON:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameLabel.text = userJSON["name"].string
        itemImageView.image = itemImage
        
        self.questionTextView.text = ""
        self.questionTextView.becomeFirstResponder()
        self.userPhoto.layer.borderWidth = 1
        self.userPhoto.layer.masksToBounds = true
        self.userPhoto.layer.borderColor = UIColor.blackColor().CGColor
        self.userPhoto.layer.cornerRadius = self.userPhoto.bounds.height / 2
        if let data = NSData(contentsOfURL: NSURL(string: String(format:"https://graph.facebook.com/%@/picture?width=80&height=80", userJSON["facebookId"].string!))!) {
            self.userPhoto.image = UIImage(data: data)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
    }
}
