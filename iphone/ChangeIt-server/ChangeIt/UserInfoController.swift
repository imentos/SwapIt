//
//  UserInfoController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 10/22/15.
//  Copyright © 2015 i818292. All rights reserved.
//

import UIKit

class UserInfoController: UIViewController {

    @IBOutlet var webview: UIWebView!
    
    @IBAction func goBack(sender: AnyObject) {
        webview.goBack()
    }
    
    @IBAction func goForward(sender: AnyObject) {
        webview.goForward()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "http://www.brttr.com/info.html")
        self.webview.loadRequest(NSURLRequest(URL: url!))
    }
}
