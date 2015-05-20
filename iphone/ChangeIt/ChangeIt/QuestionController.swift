//
//  QuestionController.swift
//  ChangeIt
//
//  Created by i818292 on 5/20/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit

class QuestionController: UITableViewController {

    @IBOutlet var questionTextView: UITextView!
    @IBOutlet var userNameLabel: UILabel!
    
    var questionJSON:JSON = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questionTextView.text = questionJSON["question"]["text"].string
        self.userNameLabel.text = questionJSON["user"]["name"].string
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
