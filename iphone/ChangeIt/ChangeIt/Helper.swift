//
//  ItemCell.swift
//  ChangeIt
//
//  Created by i818292 on 5/11/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse
import ParseUI

func displayUserPhoto(userPhoto:UIImageView, userJSON:JSON) {
    userPhoto.layer.borderWidth = 1
    userPhoto.layer.masksToBounds = true
    userPhoto.layer.borderColor = UIColor.blackColor().CGColor
    userPhoto.layer.cornerRadius = userPhoto.bounds.height / 2
    userPhoto.image = UIImage(named: "bottom_User_Inactive")
    if (userJSON["photo"] == nil) {
        if let image = NSData(contentsOfURL: NSURL(string: String(format:"https://graph.facebook.com/%@/picture?width=160&height=160", userJSON["facebookId"].string!))!) {
            userPhoto.image = UIImage(data: image)
        }
    } else {
        createImageQuery().getObjectInBackgroundWithId(userJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            userPhoto.image = UIImage(data: imageData!)
        })
    }
}

func createImageQuery()->PFQuery {
    let query = PFQuery(className:"Image")
    query.cachePolicy = .CacheElseNetwork
    return query
}
