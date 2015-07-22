//
//  MessageLabel.swift
//  ChangeIt
//
//  Created by i818292 on 7/21/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit

class MessageLabel: UILabel {
    var edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 8.0;
        self.numberOfLines = 0
    }
        
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        if (count(self.text!) == 0) {
            return bounds
        }
        var rect = edgeInsets.apply(bounds)
        rect = super.textRectForBounds(rect, limitedToNumberOfLines: numberOfLines)
        return edgeInsets.inverse.apply(rect)
    }
    
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(edgeInsets.apply(rect))
    }
}

extension UIEdgeInsets {
    var inverse : UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
    func apply(rect: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(rect, self)
    }
}

