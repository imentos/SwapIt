//
//  MyLogInViewController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 9/1/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import ParseUI

class MyLogInViewController: PFLogInViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logInView?.logo = UIImageView(image: UIImage(named: "logo_login_screen"))
        self.logInView!.logo!.contentMode = .ScaleAspectFit;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cx = self.logInView?.logo!.center.x
        let size:CGFloat = UIScreen.mainScreen().nativeBounds.width / 3
        self.logInView?.logo!.frame = CGRectMake(cx!-size/2, 0, size, size);
    }
}
