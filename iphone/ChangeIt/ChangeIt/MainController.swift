import UIKit
import Parse
import ParseUI

extension UITabBarItem {
    func tabBarItemShowingOnlyImage() -> UITabBarItem {
        // offset to center
        self.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
        // displace to hide
        self.setTitlePositionAdjustment(UIOffset(horizontal:0,vertical:30000))
        return self
    }
}

class MainController: UITabBarController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    var login:MyLogInViewController!
    
    override func viewDidAppear(animated: Bool) {
        if let user = PFUser.currentUser() {
        } else {
            showLoginPage()
        }
    }
    
    override func viewDidLoad() {
        if let user = PFUser.currentUser() {
            startItemsPage()
        }
        let tabItems = tabBar.items as! [UITabBarItem]
        for item in tabItems {
            item.tabBarItemShowingOnlyImage()
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.tabBar.frame.size.height = 60
        self.tabBar.frame.origin.y = self.view.frame.size.height - self.tabBar.frame.size.height
    }
    
    func showLoginPage() {
        login = MyLogInViewController()
        login.fields = PFLogInFields.SignUpButton | PFLogInFields.LogInButton | PFLogInFields.Facebook | PFLogInFields.UsernameAndPassword | PFLogInFields.PasswordForgotten
        login.delegate = self
        
        let signup = MySignupViewController()
        login.signUpController = signup
        
        login.signUpController?.delegate = self
        
        self.presentViewController(login, animated: true, completion: { () -> Void in
            //
        })
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        // when click an empty view controller, perform modal segue
        if (item.tag == 2) {
            self.performSegueWithIdentifier("addItem", sender: self)
        }
    }
    
    func startItemsPage() {
        self.selectedIndex = 1
        let navi = self.selectedViewController as! UINavigationController
        let itemsPage = navi.topViewController as! ItemsController
        itemsPage.loadData() { (results) -> Void in
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        if (PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!)) {
            loginFB()
        } else {
            addUser(PFUser.currentUser()!.objectId!, name:PFUser.currentUser()!.username!, facebookId:"", location:"")
        }
        
        startItemsPage()
        
        login.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        addUser(PFUser.currentUser()!.objectId!, name:PFUser.currentUser()!.username!, facebookId:"", location:"")        
        startItemsPage()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addUser(userId:String, name:String, facebookId:String, location:String) {
        PFCloud.callFunctionInBackground("getUser", withParameters: ["userId": userId], block:{
            (userFromCloud:AnyObject?, error: NSError?) -> Void in
            let userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if userJSON.count == 0 {
                PFCloud.callFunctionInBackground("addUser", withParameters: ["name": name, "objectId": userId, "facebookId": facebookId], block:{
                    (userFromCloud:AnyObject?, error: NSError?) -> Void in
                })
            } else {
                PFCloud.callFunctionInBackground("updateUser", withParameters: ["name": name, "objectId": userId, "facebookId": facebookId, "location": location], block:{
                    (userFromCloud:AnyObject?, error: NSError?) -> Void in
                })
            }
        })
    }
    
    func loginFB() {
        let permissions = ["public_profile"]
        PFFacebookUtils.logInWithPermissions(permissions, block: {
            (user: PFUser?, error: NSError?) -> Void in
            //println(user?.objectId)
            if let user = user {
                if user.isNew {
                    println("User signed up and logged in through Facebook!")
                } else {
                    println("User logged in through Facebook!")
                }
                
                var req = FBRequest.requestForMe()
                req.startWithCompletionHandler{
                    (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                    var resultdict = result as! NSDictionary
                    println("Result Dict: \(resultdict)")
                    println(resultdict["name"])
                    let name = resultdict["name"] as! String
                    let facebookId = resultdict["id"] as! String
                    
                    var location = ""
                    if resultdict["location"] != nil {
                        let loc = resultdict["location"] as! NSDictionary
                        location = loc["name"] as! String
                    }
                    
                    self.addUser(user.objectId!, name: name, facebookId: facebookId, location: location)

                }
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
            }
        })
        
    }
}