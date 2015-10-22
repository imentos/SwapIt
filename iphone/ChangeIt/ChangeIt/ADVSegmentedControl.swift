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
    
    var icons: [String] = ["Item 1", "Item 2", "Item 3"] {
        didSet {
            setupLabels()
        }
    }
    
    var selectedSegmentIndex : Int = 0 {
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
        layer.cornerRadius = 1
        layer.borderColor = UIColor(white: 1.0, alpha: 0.5).CGColor
        layer.borderWidth = 1
        
        backgroundColor = UIColor.clearColor()
        
        setupLabels()
        
        addIndividualItemConstraints(views, mainView: self, padding: 0)
        
        insertSubview(thumbView, atIndex: 0)
    }
    
    func setTitle(title:String, forSegmentAtIndex:Int) {
        print("\(views.count)")
        let view = views[forSegmentAtIndex]
        let counter = view.viewWithTag(102) as! UILabel
        counter.text = title
    }
    
    func setupLabels(){
        
        for label in views {
            label.removeFromSuperview()
        }
        
        views.removeAll(keepCapacity: true)
        
        for index in 1...items.count {
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.tag = 101
            label.text = items[index - 1]
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
//            label.font = UIFont(name: "Avenir-Black", size: 15)
            label.textColor = index == 1 ? selectedLabelColor : unselectedLabelColor
            
            let icon = UIImageView()
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.tag = 103
            icon.image = UIImage(named: icons[index - 1])
            icon.contentMode = UIViewContentMode.ScaleAspectFill
            
            let counter = UILabel()
            counter.translatesAutoresizingMaskIntoConstraints = false
            counter.tag = 102
            counter.text = "00"
            counter.textAlignment = .Center
            counter.textColor = index == 1 ? selectedLabelColor : unselectedLabelColor
            counter.backgroundColor = index == 1 ? unselectedLabelColor : selectedLabelColor
            counter.layer.cornerRadius = 15
            counter.clipsToBounds = true
            
            let view = UIView()
            view.userInteractionEnabled = false
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            view.addSubview(counter)
            view.addSubview(icon)
            
            self.addSubview(view)
            views.append(view)
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
        thumbView.layer.cornerRadius = 1
        
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
            selectedSegmentIndex = calculatedIndex!
            sendActionsForControlEvents(.ValueChanged)
        }
        
        return false
    }
    
    func displayNewSelectedIndex(){
        for (index, item) in views.enumerate() {
            let label = item.viewWithTag(101) as! UILabel
            label.textColor = unselectedLabelColor
            
            let counter = item.viewWithTag(102) as! UILabel
            counter.textColor = selectedLabelColor
            counter.backgroundColor = unselectedLabelColor
            print("\(counter.text)")
        }
        
        let view = views[selectedSegmentIndex]
        let label = view.viewWithTag(101) as! UILabel
        label.textColor = selectedLabelColor
        
        let counter = view.viewWithTag(102) as! UILabel
        counter.textColor = unselectedLabelColor
        counter.backgroundColor = selectedLabelColor
        
        
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
            
            
            
            
            
            // setup contraints for internal view
            let label = view.viewWithTag(101) as! UILabel
            let counter = view.viewWithTag(102) as! UILabel
            let icon = view.viewWithTag(103) as! UIImageView
            let dic = ["label":label, "counter":counter, "icon":icon]
            
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[icon(20)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dic))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-25-[icon(20)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dic))
            
            //
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-2-[counter(30)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dic))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[counter(30)]-(30)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dic))
            
            //
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[label]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dic))
            
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[label]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dic))
        }
    }
    
    func setSelectedColors(){
        for item in views {
            let label = item.viewWithTag(101) as! UILabel
            label.textColor = unselectedLabelColor
            
            let counter = item.viewWithTag(102) as! UILabel
            counter.textColor = unselectedLabelColor
            counter.backgroundColor = selectedLabelColor
        }
        
        if views.count > 0 {
            let label = views[0].viewWithTag(101) as! UILabel
            label.textColor = selectedLabelColor
            
            let counter = views[0].viewWithTag(102) as! UILabel
            counter.textColor = selectedLabelColor
            counter.backgroundColor = unselectedLabelColor
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
