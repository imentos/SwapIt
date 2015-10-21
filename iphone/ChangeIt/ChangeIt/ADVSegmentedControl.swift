//
//  ADVSegmentedControl.swift
//  Mega
//
//  Created by Tope Abayomi on 01/12/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

import UIKit

@IBDesignable class ADVSegmentedControl: UIControl {
    
    private var views = [UIView]()
    var thumbView = UIView()
    
    var items: [String] = ["Item 1", "Item 2", "Item 3"] {
        didSet {
            setupLabels()
        }
    }
    
    var selectedIndex : Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    
    @IBInspectable var selectedLabelColor : UIColor = UIColor.blackColor() {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var unselectedLabelColor : UIColor = UIColor.whiteColor() {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var thumbColor : UIColor = UIColor.whiteColor() {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var borderColor : UIColor = UIColor.whiteColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var font : UIFont! = UIFont.systemFontOfSize(12) {
        didSet {
            setFont()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView(){
        
        layer.cornerRadius = frame.height / 2
        layer.borderColor = UIColor(white: 1.0, alpha: 0.5).CGColor
        layer.borderWidth = 2
        
        backgroundColor = UIColor.clearColor()
        
        setupLabels()
        
        addIndividualItemConstraints(views, mainView: self, padding: 0)
        
        insertSubview(thumbView, atIndex: 0)
    }
    
    func setupLabels(){
        
        for label in views {
            label.removeFromSuperview()
        }
        
        views.removeAll(keepCapacity: true)
        
        for index in 1...items.count {
            
            let label = UILabel(frame: CGRectMake(0, 0, 70, 40))
            label.userInteractionEnabled = true
            label.text = items[index - 1]
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
            label.font = UIFont(name: "Avenir-Black", size: 15)
            label.textColor = index == 1 ? selectedLabelColor : unselectedLabelColor
            label.translatesAutoresizingMaskIntoConstraints = false
            label.tag = 101
            
            
            

            
            
            
            
            
            
            let button = UIButton(frame: CGRectMake(0, 0, 70, 40))
            button.setTitle("test", forState: .Normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = 102
            
            
            
            let view = UIView()
            view.userInteractionEnabled = false
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            view.addSubview(button)
            
            self.addSubview(view)
            views.append(view)
            
            
            
            
            
            



            view.updateConstraints()

            
        }
        
        addIndividualItemConstraints(views, mainView: self, padding: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectFrame = self.bounds
        let newWidth = CGRectGetWidth(selectFrame) / CGFloat(items.count)
        selectFrame.size.width = newWidth
        thumbView.frame = selectFrame
        thumbView.backgroundColor = thumbColor
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
        
        displayNewSelectedIndex()
        
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        let location = touch.locationInView(self)
        
        var calculatedIndex : Int?
        for (index, item) in views.enumerate() {
            let label = item.viewWithTag(101) as! UILabel
            print("\(label.superview!.frame),\(location)")
            if label.superview!.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActionsForControlEvents(.ValueChanged)
        }
        
        return false
    }
    
    func displayNewSelectedIndex(){
        for (index, item) in views.enumerate() {
            let label = item.viewWithTag(101) as! UILabel
            label.textColor = unselectedLabelColor
        }
        
        let view = views[selectedIndex]
        let label = view.viewWithTag(101) as! UILabel
        label.textColor = selectedLabelColor
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            
            self.thumbView.frame = label.superview!.frame
            
            }, completion: nil)
    }
    
    func addIndividualItemConstraints(items: [UIView], mainView: UIView, padding: CGFloat) {
        
        let constraints = mainView.constraints
        
        for (index, view) in items.enumerate() {
            
            let topConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
            
            let bottomConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == items.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -padding)
                
            }else{
                
                let nextButton = items[index+1]
                rightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: nextButton, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: -padding)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: padding)
                
            }else{
                
                let prevButton = items[index-1]
                leftConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: prevButton, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: padding)
                
                let firstItem = items[0]
                
                let widthConstraint = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: NSLayoutRelation.Equal, toItem: firstItem, attribute: .Width, multiplier: 1.0  , constant: 0)
                
                mainView.addConstraint(widthConstraint)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
            
            
            
            
            
            
            let label = view.viewWithTag(101) as! UILabel
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[item]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: Dictionary(dictionaryLiteral: ("item",label))
            )
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[item]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: Dictionary(dictionaryLiteral: ("item",label))
            )
            view.addConstraints(hConstraints)
            view.addConstraints(vConstraints)
        }
    }
    
    func setSelectedColors(){
        for item in views {
            let label = item.viewWithTag(101) as! UILabel
            label.textColor = unselectedLabelColor
        }
        
        if views.count > 0 {
            let label = views[0].viewWithTag(101) as! UILabel
            label.textColor = selectedLabelColor
        }
        
        thumbView.backgroundColor = thumbColor
    }
    
    func setFont(){
        for item in views {
            let label = item.viewWithTag(101) as! UILabel
            label.font = font
        }
    }
}
