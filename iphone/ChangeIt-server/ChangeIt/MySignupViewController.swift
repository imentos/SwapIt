//
//  MyLogInViewController.swift
//  ChangeIt
//
//  Created by Kuo, Ray on 9/1/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import ParseUI

class MySignupViewController: PFSignUpViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signUpView?.logo = UIImageView(image: UIImage(named: "login_screen_logo"))
        self.signUpView!.logo!.contentMode = .ScaleAspectFit;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cx = self.signUpView?.logo!.center.x
        let size:CGFloat = UIScreen.mainScreen().nativeBounds.width / 6
        self.signUpView?.logo!.frame = CGRectMake(cx!-size/2, size/2, size, size);
    }
}
