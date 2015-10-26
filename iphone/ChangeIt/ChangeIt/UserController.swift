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
    
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet var spinnerView: UIActivityIndicatorView!
    @IBOutlet weak var offerReceivedButton: UIButton!
    
    var sentOffersJSON:JSON! = nil
    var receivedOffersJSON:JSON! = nil
    var userJSON:JSON!
    var picker:UIImagePickerController? = UIImagePickerController()
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        self.navigationController?.navigationBarHidden = true
    }
    
    @IBAction func unwindToUser(segue:UIStoryboardSegue) {
        self.navigationController?.navigationBarHidden = true
    }

    @IBAction func saveEmail(segue:UIStoryboardSegue) {
        self.navigationController?.navigationBarHidden = true
        self.loadData()
    }
    
    @IBAction func savePhone(segue:UIStoryboardSegue) {
        self.navigationController?.navigationBarHidden = true
        self.loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker!.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "editImage")
        tap.numberOfTapsRequired = 1
        self.userPhoto.userInteractionEnabled = true
        self.userPhoto.addGestureRecognizer(tap)
    }
    
    @IBAction func logout(sender: AnyObject) {
        let currentInstall = PFInstallation.currentInstallation()
        currentInstall["user"] = NSNull()
        currentInstall.saveInBackgroundWithBlock { (result, error) -> Void in
            //
        }
        PFUser.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let main = UIApplication.sharedApplication().keyWindow?.rootViewController as! MainController
        main.showLoginPage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
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
                self.title = self.userJSON["name"].string
                self.nameLabel.text = self.userJSON["name"].string
                
                if (self.userJSON["email"] == nil || self.userJSON["email"].string?.isEmpty == true) {
                    self.emailButton.setImage(UIImage(named: "mail_grey"), forState: .Normal)
                } else {
                    self.emailButton.setImage(UIImage(named: "mail_red"), forState: .Normal)
                }
                
                if (self.userJSON["phone"] == nil || self.userJSON["phone"].string?.isEmpty == true) {
                    self.phoneButton.setImage(UIImage(named: "phone_grey"), forState: .Normal)
                } else {
                    self.phoneButton.setImage(UIImage(named: "phone_red"), forState: .Normal)
                }
                
                displayUserPhoto(self.userPhoto, userJSON: self.userJSON)
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBarHidden = false
        
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
            view.loadDataByFunction("getBookmarkedItems", limit:view.ITEMS_PER_PAGE) { (results) -> Void in
            }
            
        } else if (segue.identifier == "questions") {
            let view = segue.destinationViewController as! QuestionsController
            view.title = "Questions Asked"
            view.loadData()
        
        } else if (segue.identifier == "email") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.topViewController as! UserEmailController
            view.email = self.userJSON["email"].string

        } else if (segue.identifier == "phone") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.topViewController as! UserPhoneController
            view.phone = self.userJSON["phone"].string
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
        let scaledImage = resizeImage(image)
        self.userPhoto.layer.borderWidth = 1
        self.userPhoto.layer.masksToBounds = true
        self.userPhoto.layer.borderColor = UIColor.blackColor().CGColor
        self.userPhoto.layer.cornerRadius = self.userPhoto.bounds.height / 2
        self.userPhoto.image = scaledImage
        
        let imageFile = PFFile(name:"image.png", data:UIImagePNGRepresentation(scaledImage)!)
        let imageObj = PFObject(className:"Image")
        imageObj["file"] = imageFile
        imageObj.saveInBackgroundWithBlock { (result, error) -> Void in
            PFCloud.callFunctionInBackground("updateUserPhoto", withParameters: ["userId":(PFUser.currentUser()?.objectId)!, "photo": imageObj.objectId!], block:{
                (userFromCloud:AnyObject?, error: NSError?) -> Void in
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

