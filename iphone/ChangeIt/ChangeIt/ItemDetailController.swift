//
//  ItemDetailController.swift
//  ChangeIt
//
//  Created by i818292 on 5/5/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class ItemDetailController: UITableViewController {

    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var itemJSON:JSON!
    var userJSON:JSON!
    
    @IBAction func makeOffer(segue:UIStoryboardSegue) {
        let offer = segue.sourceViewController as! MakeOfferController
        let offerJSON:JSON = offer.selectedItem!
        
        let srcId = offerJSON["objectId"].string
        let distId = itemJSON["objectId"].string
        PFCloud.callFunction("exchangeItem", withParameters: ["srcItemId":srcId!, "distItemId":distId!])
    }

    @IBAction func cancel(segue:UIStoryboardSegue) {
        println("cancel")
    }
    
    @IBAction func sendQuestion(segue:UIStoryboardSegue) {
        let view = segue.sourceViewController as! QuestionController
        let uuid = NSUUID().UUIDString
        
        PFCloud.callFunctionInBackground("addQuestion", withParameters: ["text": view.questionTextView.text, "objectId": uuid], block:{
            (items:AnyObject?, error: NSError?) -> Void in
            
            self.linkQuestion(uuid)
        })
    }
    
    func linkQuestion(questionId:String) {
        let itemId = self.itemJSON["objectId"].string
        PFCloud.callFunctionInBackground("askItemQuestionByUser", withParameters: ["userId": (PFUser.currentUser()?.objectId)!, "itemId": itemId!, "questionId": questionId], block:{
            (items:AnyObject?, error: NSError?) -> Void in
        })
        
    }
    
    func loadData() {
        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.photoImage.image = UIImage(data: imageData!)
        })
        
        self.title = itemJSON["title"].string
        self.descriptionTextView.text = itemJSON["description"].string
        self.userLabel.text = userJSON["name"].string
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showUserWishList") {
            let navi = segue.destinationViewController as! UINavigationController
            let view = navi.childViewControllers[0] as! WishListController
            view.loadData(self.userJSON["objectId"].string, hideAddCell: true)
            view.toolbar.rightBarButtonItem = nil
            
        } else if (segue.identifier == "offer") {
            let view = segue.destinationViewController as! MakeOfferController
            view.loadData()
        } else if (segue.identifier == "askQuestion") {
            let view = segue.destinationViewController as! QuestionController
            view.userName = self.userLabel.text!
            view.itemImage = self.photoImage.image!
        }
    }
}
