//
//  FirstViewController.swift
//  ChangeIt
//
//  Created by i818292 on 4/22/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class UserController: UIViewController, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var offerReceivedButton: UIButton!
    
    var sentOffersJSON:JSON! = nil
    var receivedOffersJSON:JSON! = nil
    var userJSON:JSON!
    var picker:UIImagePickerController? = UIImagePickerController()
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
    }
    
    @IBAction func unwindToUser(segue:UIStoryboardSegue) {
    }

    @IBAction func saveSettings(segue:UIStoryboardSegue) {
        NSNotificationCenter.defaultCenter().postNotificationName(EVENT_RELOAD, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker!.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "editImage")
        tap.numberOfTapsRequired = 1
        self.userPhoto.userInteractionEnabled = true
        self.userPhoto.addGestureRecognizer(tap)
        
        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //        updateTotalUnreadCount()
    }
    
    @IBAction func logout(sender: AnyObject) {
        let alert:UIAlertController = UIAlertController(title: "Alert", message: "Are you sure that you want to log out?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let currentInstall = PFInstallation.currentInstallation()
            currentInstall["user"] = NSNull()
            currentInstall.saveInBackgroundWithBlock { (result, error) -> Void in
                //
            }
            PFUser.logOut()
            self.dismissViewControllerAnimated(true, completion: nil)
            
            let main = UIApplication.sharedApplication().keyWindow?.rootViewController as! MainController
            main.showLoginPage()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateTotalUnreadCount() {
        if let _=PFUser.currentUser() {            
        } else {
            return
        }
        var totalUnread:Int = 0
        let spinner = createSpinner(self.view)
        PFCloud.callFunctionInBackground("getUnreadRepliesCount", withParameters:["userId": (PFUser.currentUser()?.objectId)!], block: {
            (result:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                spinner.stopAnimating()
                return
            }
            let countJSON = JSON(data:(result as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            totalUnread += countJSON[0].int!
            
            let app:AppDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
            app.updateTabBadge(0, value: totalUnread == 0 ? nil : "")
            spinner.stopAnimating()
        })
    }
    
    func loadData() {
        if let user = PFUser.currentUser() {
            let spinner = createSpinner(self.view)
            PFCloud.callFunctionInBackground("getUser", withParameters: ["userId": user.objectId!], block:{
                (userFromCloud:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    spinner.stopAnimating()
                    return
                }
                self.userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)[0]
                self.title = self.userJSON["name"].string
                
                displayUserPhoto(self.userPhoto, userJSON: self.userJSON)
                spinner.stopAnimating()
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "wishList") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.viewControllers[0] as! WishListController
            view.title = "Wish List"
            view.loadData(PFUser.currentUser()?.objectId!, otherWishlist: false)
            
        } else if (segue.identifier == "bookmarks") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.topViewController as! ItemsController
            view.title = "Bookmarks"
            view.bookmarkMode = true
            view.loadDataByFunction("getBookmarkItems", limit:view.ITEMS_PER_PAGE) { (results) -> Void in
            }
            
        } else if (segue.identifier == "questions") {
            let view = segue.destinationViewController as! QuestionsController
            view.title = "Questions Asked"
            view.loadData()
        
        } else if (segue.identifier == "settings") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.topViewController as! UserSettingsController
            view.userJSON = self.userJSON
            
        }
    }
    
    func editImage() {
        let alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        
        // Present the actionsheet
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker!, animated: true, completion: nil)
        } else {
            openGallary()
        }
    }
    
    func openGallary() {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: nil)

        let scaledImage = resizeImage(image)
        self.userPhoto.layer.borderWidth = 1
        self.userPhoto.layer.masksToBounds = true
        self.userPhoto.layer.borderColor = UIColor.blackColor().CGColor
        self.userPhoto.layer.cornerRadius = self.userPhoto.bounds.height / 2
        self.userPhoto.image = scaledImage
        
        let imageFile = PFFile(name:"image.png", data:UIImagePNGRepresentation(scaledImage)!)
        let imageObj = PFObject(className:"Image")
        imageObj["file"] = imageFile
        let spinner = createSpinner(self.view)
        imageObj.saveInBackgroundWithBlock { (result, error) -> Void in
            PFCloud.callFunctionInBackground("updateUserPhoto", withParameters: ["userId":(PFUser.currentUser()?.objectId)!, "photo": imageObj.objectId!], block:{
                (userFromCloud:AnyObject?, error: NSError?) -> Void in 
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    spinner.stopAnimating()
                    return
                }
                spinner.stopAnimating()
            })
        }
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.1, 0.1))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

