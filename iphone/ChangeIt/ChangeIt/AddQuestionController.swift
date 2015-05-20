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
    
    var userName:String = ""
    var itemImage:UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameLabel.text = userName
        itemImageView.image = itemImage
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
