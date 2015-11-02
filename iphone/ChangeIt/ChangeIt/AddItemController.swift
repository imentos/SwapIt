import UIKit
import Parse
import AVFoundation
import ImageIO

// This class is also for editing item
class AddItemController: UITableViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    var imageId: String!
    
    var picker:UIImagePickerController? = UIImagePickerController()
    
    var communications:Set<String> = Set<String>()
    var itemJSON:JSON!
    var userJSON:JSON!
    
    private let TEXT_VIEW_PLACE_HOLDER = "Add some description"
    
    @IBAction func saveEmail(segue:UIStoryboardSegue) {
        self.loadUser()
    }
    
    @IBAction func savePhone(segue:UIStoryboardSegue) {
        self.loadUser()
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker!.delegate = self
        
        self.addImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.titleTextField.delegate = self
        
        self.descriptionTextView.delegate = self
        self.descriptionTextView.text = TEXT_VIEW_PLACE_HOLDER
        self.descriptionTextView.backgroundColor = UIColor.clearColor()
        if navigationItem.rightBarButtonItem != self.saveButton {
            self.descriptionTextView.textColor = UIColor.lightGrayColor()
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
    }
    
    func loadUser() {
        if let user = PFUser.currentUser() {
            PFCloud.callFunctionInBackground("getUser", withParameters: ["userId": user.objectId!], block:{
                (userFromCloud:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    return
                }
                self.userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)[0]
            })
        }
    }
    
    func loadData() {
        self.loadUser()
        
        communications.removeAll()
        self.emailButton.setImage(UIImage(named: "mail_grey"), forState: .Normal)
        self.phoneButton.setImage(UIImage(named: "phone_grey"), forState: .Normal)
        
        if let _ = itemJSON {
        } else {
            return
        }
        self.imageId = itemJSON["photo"].string!
        createImageQuery().getObjectInBackgroundWithId(self.imageId, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.addImageButton.setImage(UIImage(data: imageData!), forState: .Normal)
        })
        self.titleTextField.text = self.itemJSON["title"].string!
        self.descriptionTextView.text = self.itemJSON["description"].string!
        self.communications = Set<String>(self.itemJSON["communication"].string!.componentsSeparatedByString(","))
        
        updateCommunications()
    }
    
    func updateCommunications() {
        self.emailButton.setImage(UIImage(named: communications.contains("email") == false ? "mail_grey" : "mail_red"), forState: .Normal)
        self.phoneButton.setImage(UIImage(named: communications.contains("phone") == false ? "phone_grey" : "phone_red"), forState: .Normal)
    }
    
    @IBAction func saveItem(sender: AnyObject) {
        PFCloud.callFunctionInBackground("updateItem", withParameters: ["itemId": self.itemJSON["objectId"].string!, "title": titleTextField.text!, "description": descriptionTextView.text!, "photo": imageId, "communication": self.communications.joinWithSeparator(",")], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            self.performSegueWithIdentifier("cancel", sender: self)
        })
    }
    
    @IBAction func addItem(sender: AnyObject) {
        self.validateTitle()
        self.validateDescription()
        self.validate(imageId == nil, view:nil)
        if (titleTextField.text == "" || descriptionTextView.text == TEXT_VIEW_PLACE_HOLDER || imageId == nil) {
            return
        }
        
        let uuid = NSUUID().UUIDString
        PFCloud.callFunctionInBackground("addItem", withParameters: ["objectId": uuid, "title": titleTextField.text!, "description": descriptionTextView.text!, "photo": imageId, "communication": self.communications.joinWithSeparator(",")], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                return
            }
            PFCloud.callFunctionInBackground("linkMyItem", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": uuid], block:{
                (results:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    return
                }
                let item = PFObject(className: "Item")
                item["neo4jId"] = uuid
                item.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        PFGeoPoint.geoPointForCurrentLocationInBackground {
                            (geoPoint, error) -> Void in
                            if let error = error {
                                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                                return
                            }
                            item.setObject(geoPoint!, forKey: "currentLocation")
                            item.saveInBackgroundWithBlock({
                                (result, error) -> Void in
                                if let error = error {
                                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                                    return
                                }
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.performSegueWithIdentifier("addItem", sender: self)
                                })
                            })
                        }
                    } else {
                        // There was a problem, check error.description
                    }
                }
            })
        })
    }
    
    @IBAction func addEmail(sender: AnyObject) {
        if let email = self.userJSON["email"].string {
            if (email.isEmpty == true) {
                performSegueWithIdentifier("email", sender: self)
                return
            }
        } else {
            performSegueWithIdentifier("email", sender: self)
            return
        }
        
        if (communications.contains("email") == true) {
            self.emailButton.setImage(UIImage(named: "mail_grey"), forState: .Normal)
            communications.remove("email")
        } else {
            self.emailButton.setImage(UIImage(named: "mail_red"), forState: .Normal)
            communications.insert("email")
        }
    }
    
    @IBAction func addPhone(sender: AnyObject) {
        if let phone = self.userJSON["phone"].string {
            if (phone.isEmpty == true) {
                performSegueWithIdentifier("phone", sender: self)
                return
            }
        } else {
            performSegueWithIdentifier("phone", sender: self)
            return
        }
        
        if (communications.contains("phone") == true) {
            self.phoneButton.setImage(UIImage(named: "phone_grey"), forState: .Normal)
            communications.remove("phone")
        } else {
            self.phoneButton.setImage(UIImage(named: "phone_red"), forState: .Normal)
            communications.insert("phone")
        }
    }
    
    @IBAction func addImage(sender: AnyObject) {
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
        addImageButton.setImage(scaledImage, forState: .Normal)
        
        let imageFile = PFFile(name:"image.png", data:UIImagePNGRepresentation(scaledImage)!)
        let imageObj = PFObject(className:"Image")
        imageObj["file"] = imageFile
        imageObj.saveInBackgroundWithBlock { (result, error) -> Void in
            self.imageId = imageObj.objectId
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
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
//        validateTitle()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let count = textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) + (text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - range.length)
        print(count)
        if (count > 200) {
            let alert = UIAlertView(title: "Brttr", message: "You have entered the description over 200 characters. Try to limit your description.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
        return count <= 200
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.titleTextField.resignFirstResponder()
        return true
    }
    
    func validateTitle() {
        let invalid = self.titleTextField.text!.isEmpty;
        self.validate(invalid, view: self.titleTextField)
    }
    
    func validateDescription() {
        let invalid = self.descriptionTextView.text == TEXT_VIEW_PLACE_HOLDER;
        self.validate(invalid, view: self.descriptionTextView)
    }
    
    func validate(invalid:Bool, view:UIView?) {
        if (invalid == true) {
            let alert = UIAlertController(title: "Alert", message: "Please complete all required fields before continuing.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
//        if (invalid) {
//            view.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2)
//        } else {
//            view.backgroundColor = UIColor.clearColor()
//        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (self.descriptionTextView.text == TEXT_VIEW_PLACE_HOLDER) {
            self.descriptionTextView.text = ""
            self.descriptionTextView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (self.descriptionTextView.text == "") {
            self.descriptionTextView.text = TEXT_VIEW_PLACE_HOLDER
            self.descriptionTextView.textColor = UIColor.lightGrayColor()
        }
        
//        validateDescription()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
