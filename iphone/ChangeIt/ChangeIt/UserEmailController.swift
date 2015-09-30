//
//  UserEmailController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 9/29/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit

class UserEmailController : UIViewController {
    @IBOutlet weak var emailText: UITextField!
    
    var email:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailText.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.emailText.text = email
    }
    
    @IBAction func editEmail(sender: AnyObject) {
        self.email = self.emailText.text
    }
}
