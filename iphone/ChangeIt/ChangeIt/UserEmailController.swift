//
//  UserEmailController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 9/29/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

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
    
    @IBAction func save(sender: AnyObject) {
        let email = emailText.text
        PFCloud.callFunctionInBackground("updateUserEmail", withParameters: ["userId":(PFUser.currentUser()?.objectId)!, "email": email!], block:{
            (userFromCloud:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            
            self.performSegueWithIdentifier("save", sender: self)
        })
    }
    
    @IBAction func editEmail(sender: AnyObject) {
        self.email = self.emailText.text
    }
}
