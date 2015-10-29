//
//  UserSettingsController.swift
//  Brttr
//
//  Created by Kuo, Ray on 10/28/15.
//  Copyright © 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class UserSettingsController: UIViewController {
    var userJSON:JSON!
    
    @IBOutlet var phoneButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var slider: UISlider!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var phoneText: UITextField!
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
    }
    
    @IBAction func saveEmail(segue:UIStoryboardSegue) {
        self.loadData()
    }
    
    @IBAction func savePhone(segue:UIStoryboardSegue) {
        self.loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _:JSON = userJSON["distance"] {
            slider.value = userJSON["distance"].floatValue
        } else {
            slider.value = 50.0
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        if let user = PFUser.currentUser() {
            PFCloud.callFunctionInBackground("getUser", withParameters: ["userId": user.objectId!], block:{
                (userFromCloud:AnyObject?, error: NSError?) -> Void in
                self.userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)[0]
                if (self.userJSON["email"] == nil || self.userJSON["email"].string?.isEmpty == true) {
                    self.emailButton.setImage(UIImage(named: "mail_grey"), forState: .Normal)
                    self.emailText.text = ""
                } else {
                    self.emailButton.setImage(UIImage(named: "mail_red"), forState: .Normal)
                    self.emailText.text = self.userJSON["email"].string
                }
                
                if (self.userJSON["phone"] == nil || self.userJSON["phone"].string?.isEmpty == true) {
                    self.phoneButton.setImage(UIImage(named: "phone_grey"), forState: .Normal)
                    self.phoneText.text = ""
                } else {
                    self.phoneButton.setImage(UIImage(named: "phone_red"), forState: .Normal)
                    self.phoneText.text = self.userJSON["phone"].string
                }
            })
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        let distance = Int(self.slider.value)
        PFCloud.callFunctionInBackground("updateUserSearchDistance", withParameters: ["userId":(PFUser.currentUser()?.objectId)!, "distance": distance], block:{
            (userFromCloud:AnyObject?, error: NSError?) -> Void in
            
            self.performSegueWithIdentifier("save", sender: self)
        })
    }
    
    @IBAction func sliderChange(sender: UISlider) {
        var currentValue = Int(sender.value)
        print("\(currentValue)")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "email") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.topViewController as! UserEmailController
            view.email = self.userJSON["email"].string
                        
        } else if (segue.identifier == "phone") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.topViewController as! UserPhoneController
            view.phone = self.userJSON["phone"].string
        }
    }
    
}
