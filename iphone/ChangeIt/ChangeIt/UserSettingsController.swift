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
    
    @IBOutlet var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _:JSON = userJSON["distance"] {
            slider.value = userJSON["distance"].floatValue
        } else {
            slider.value = 50.0
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
    
}
