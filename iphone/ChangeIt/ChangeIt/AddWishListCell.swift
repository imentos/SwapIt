//
//  AddWishListCell.swift
//  ChangeIt
//
//  Created by i818292 on 5/15/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit

class AddWishListCell: UITableViewCell {

    @IBAction func textAction(sender: AnyObject) {
        addButton.enabled = newWishListText.text != ""
    }
    @IBOutlet var addButton: UIButton!
    @IBOutlet var newWishListText: UITextField!
}
