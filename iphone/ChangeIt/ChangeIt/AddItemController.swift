import UIKit
import Parse
import AVFoundation
import ImageIO

class AddItemController: UIViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var frameView: UIView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    var imageId: String!
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverController?=nil
    
    var communications:Set<String> = Set<String>()
    var itemJSON:JSON!
    
    private let TEXT_VIEW_PLACE_HOLDER = "Add some description"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker!.delegate = self
        
        self.addImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.titleTextField.delegate = self
        
        self.descriptionTextView.delegate = self
        self.descriptionTextView.text = TEXT_VIEW_PLACE_HOLDER
        self.descriptionTextView.backgroundColor = UIColor.clearColor()
        self.descriptionTextView.textColor = UIColor.lightGrayColor()
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        // Keyboard stuff.
        let center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

    }
    
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        loadData()
    }

    func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardHeight: CGFloat = keyboardSize.height
        
        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
        
        
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.frameView.frame = CGRectMake(0, (self.frameView.frame.origin.y - keyboardHeight), self.view.bounds.width, self.view.bounds.height)
            }, completion: nil)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info: NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardHeight: CGFloat = keyboardSize.height
        
        let _: CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber as CGFloat
        
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.frameView.frame = CGRectMake(0, (self.frameView.frame.origin.y + keyboardHeight), self.view.bounds.width, self.view.bounds.height)
            }, completion: nil)
        
    }
    
    func loadData() {
        if let x = itemJSON {
        } else {
            return
        }
        self.imageId = itemJSON["photo"].string!
        PFQuery(className:"Image").getObjectInBackgroundWithId(self.imageId, block: {
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
        PFCloud.callFunctionInBackground("updateItem", withParameters: ["itemId": self.itemJSON["objectId"].string!, "title": titleTextField.text!, "description": descriptionTextView.text!, "photo": imageId, "communication": join(",", self.communications)], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            self.performSegueWithIdentifier("cancel", sender: self)
        })
    }
    
    @IBAction func addItem(sender: AnyObject) {
        self.validateTitle()
        self.validateDescription()
        if (titleTextField.text == "" || descriptionTextView.text == TEXT_VIEW_PLACE_HOLDER || imageId == nil) {
            return
        }
        
        let uuid = NSUUID().UUIDString
        PFCloud.callFunctionInBackground("addItem", withParameters: ["objectId": uuid, "title": titleTextField.text!, "description": descriptionTextView.text!, "photo": imageId, "communication": join(",", self.communications)], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            PFCloud.callFunctionInBackground("linkMyItem", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": uuid], block:{
                (results:AnyObject?, error: NSError?) -> Void in
                var item = PFObject(className: "Item")
                item["neo4jId"] = uuid
                item.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        PFGeoPoint.geoPointForCurrentLocationInBackground {
                            (geoPoint, error) -> Void in
                            item.setObject(geoPoint!, forKey: "currentLocation")
                            item.saveInBackgroundWithBlock({
                                (result, error) -> Void in
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
        if (communications.contains("email") == true) {
            self.emailButton.setImage(UIImage(named: "mail_grey"), forState: .Normal)
            communications.remove("email")
        } else {
            self.emailButton.setImage(UIImage(named: "mail_red"), forState: .Normal)
            communications.insert("email")
        }
    }
    
    @IBAction func addPhone(sender: AnyObject) {
        if (communications.contains("phone") == true) {
            self.phoneButton.setImage(UIImage(named: "phone_grey"), forState: .Normal)
            communications.remove("phone")
        } else {
            self.phoneButton.setImage(UIImage(named: "phone_red"), forState: .Normal)
            communications.insert("phone")
        }
    }
    
    @IBAction func addImage(sender: AnyObject) {
        var alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openCamera()
        }
        var gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openGallary()
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let image:UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        let scaledImage = resizeImage(image)
        addImageButton.setImage(scaledImage, forState: .Normal)
        
        let imageFile = PFFile(name:"image.png", data:UIImagePNGRepresentation(scaledImage))
        var imageObj = PFObject(className:"Image")
        imageObj["file"] = imageFile
        imageObj.save()
        
        self.imageId = imageObj.objectId
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
        validateTitle()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.titleTextField.resignFirstResponder()
        return true
    }
    
    func validateTitle() {
        let invalid = self.titleTextField.text.isEmpty;
        self.validate(invalid, view: self.titleTextField)
    }
    
    func validateDescription() {
        let invalid = self.descriptionTextView.text == TEXT_VIEW_PLACE_HOLDER;
        self.validate(invalid, view: self.descriptionTextView)
    }
    
    func validate(invalid:Bool, view:UIView) {
        if (invalid) {
            view.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2)
        } else {
            view.backgroundColor = UIColor.clearColor()
        }
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
        
        validateDescription()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
