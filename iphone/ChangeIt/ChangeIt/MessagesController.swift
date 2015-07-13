//
//  MessagesController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 7/12/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class MessagesController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dockHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    var questionJSON:JSON = nil
    var repliesJSON:JSON = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        
        let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableTapped")
        self.messageTableView.addGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableTapped() {
        self.messageTextField.endEditing(true)
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        self.messageTextField.text = ""
        self.messageTextField.endEditing(true)
    }
    
    @IBAction func endEditing(sender: AnyObject) {
        self.view.layoutIfNeeded()
        self.dockHeightConstraint.constant = 50
    }
    
    @IBAction func startEditing(sender: AnyObject) {
        self.view.layoutIfNeeded()
        self.dockHeightConstraint.constant = 300
    }
    
    func loadData() {
        PFCloud.callFunctionInBackground("getAskedQuestions", withParameters: ["userId":(PFUser.currentUser()?.objectId)!], block: {
            (replies:AnyObject?, error: NSError?) -> Void in
            self.repliesJSON = JSON(data:(replies as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.messageTableView.reloadData()
        })
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.messageTableView.dequeueReusableCellWithIdentifier("message") as! UITableViewCell
        cell.textLabel?.text = "test"
        
//        let offerJSON = offersJSON[indexPath.row]
//        
//        PFQuery(className:"Image").getObjectInBackgroundWithId(offerJSON["src"]["photo"].string!, block: {
//            (imageObj:PFObject?, error: NSError?) -> Void in
//            let imageData = (imageObj!["file"] as! PFFile).getData()
//            (cell.viewWithTag(101) as! UIImageView).image = UIImage(data: imageData!)
//        })
//        
//        let label = cell.viewWithTag(102) as! UILabel
//        label.text = offerJSON["src"]["title"].string
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
