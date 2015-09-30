//
//  UserPhoneController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 9/29/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit

class UserPhoneController : UIViewController {
    @IBOutlet weak var phoneText: UITextField!
    
    var phone:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.phoneText.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.phoneText.text = phone
    }
    
    @IBAction func editPhone(sender: AnyObject) {
        self.phone = self.phoneText.text
    }
}
