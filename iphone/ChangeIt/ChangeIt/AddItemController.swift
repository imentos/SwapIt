import UIKit
import Parse
import AVFoundation
import ImageIO

class AddItemController: UITableViewController,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var addImageInfo: UILabel!
    @IBOutlet var camerView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    var imageId: String!
    
    @IBOutlet weak var imageView: UIImageView!
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverController?=nil
    
    private let TEXT_VIEW_PLACE_HOLDER = "Add some description"
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addItem" {
            let uuid = NSUUID().UUIDString
            PFCloud.callFunction("addItem", withParameters: ["objectId": uuid, "title": titleTextField.text!, "description": descriptionTextView.text!, "photo": imageId, "communication": ""])
            PFCloud.callFunction("linkMyItem", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": uuid])
            
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
                            //
                        })
                    }
                } else {
                    // There was a problem, check error.description
                }
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if (identifier == "addItem") {
            self.validateTitle()
            self.validateDescription()
            if (titleTextField.text == "" || descriptionTextView.text == TEXT_VIEW_PLACE_HOLDER || imageId == nil) {
                
                return false
            }
            return true
        }        
        return true
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
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
        imageView.image = scaledImage
        
        let imageFile = PFFile(name:"image.png", data:UIImagePNGRepresentation(scaledImage))
        var imageObj = PFObject(className:"Image")
        imageObj["file"] = imageFile
        imageObj.save()
        
        self.imageId = imageObj.objectId
        
        self.addImageInfo.hidden = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker!.delegate = self
        
        self.titleTextField.delegate = self
        
        self.descriptionTextView.delegate = self
        self.descriptionTextView.text = TEXT_VIEW_PLACE_HOLDER
        self.descriptionTextView.backgroundColor = UIColor.clearColor()
        self.descriptionTextView.textColor = UIColor.lightGrayColor()
        
        let recognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
        self.camerView.addGestureRecognizer(recognizer)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        validateTitle()
    }
    
    func validateTitle() {
        let invalid = self.titleTextField.text.isEmpty;
        self.validate(invalid, view: self.titleTextField.superview!)
    }
    
    func validateDescription() {
        let invalid = self.descriptionTextView.text == TEXT_VIEW_PLACE_HOLDER;
        self.validate(invalid, view: self.descriptionTextView.superview!)
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            titleTextField.becomeFirstResponder()
        }
    }
}
