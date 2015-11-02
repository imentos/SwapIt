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
    @IBOutlet var distanceLabel: UILabel!
    
    let numbers = [5, 50, 100, 0]
    
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
        
        self.slider.maximumValue = Float(numbers.count - 1)
        self.slider.minimumValue = 0
        
        self.title = "Settings"
        if let _ = userJSON {
            if let _ = userJSON["distance"].float {
                let value = numbers.indexOf(userJSON["distance"].intValue)
                slider.value = Float(value!)
            } else {
                slider.value = 3 // default is 0
            }
        }
        updateDistanceLabel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        if let user = PFUser.currentUser() {
            PFCloud.callFunctionInBackground("getUser", withParameters: ["userId": user.objectId!], block:{
                (userFromCloud:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    return
                }
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
        let distance = getSliderValue()
        PFCloud.callFunctionInBackground("updateUserSearchDistance", withParameters: ["userId":(PFUser.currentUser()?.objectId)!, "distance": distance], block:{
            (userFromCloud:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            
            self.performSegueWithIdentifier("save", sender: self)
        })
    }
    
    func getSliderValue()->Int {
        let index = Int(self.slider.value + 0.5)
        self.slider.value = Float(index)
        return numbers[index]
    }
    
    func updateDistanceLabel() {
        let value = getSliderValue()
        if (value == 0) {
            distanceLabel.text = "I am interested in bartering within whole world."
        } else {
            distanceLabel.text = "I am interested in bartering within \(value) miles."
        }
        
    }
    
    @IBAction func sliderChange(sender: UISlider) {
        updateDistanceLabel()
        print(getSliderValue())
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
