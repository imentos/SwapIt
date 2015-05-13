//
//  OfferDetailController.swift
//  ChangeIt
//
//  Created by i818292 on 5/7/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class OfferDetailController: UITableViewController {
    var itemJSON:JSON!
    var userJSON:JSON!
    var otherItemJSON:JSON!

    @IBOutlet var itemDescription: UITextView!
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var itemImageView: UIImageView!    
    @IBOutlet var otherItemImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.itemImageView.image = UIImage(data: imageData!)
        })
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(otherItemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            self.otherItemImageView.image = UIImage(data: imageData!)
        })

        self.title = itemJSON["title"].string
        self.itemDescription.text = itemJSON["description"].string
        self.userLabel.text = userJSON["name"].string
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
