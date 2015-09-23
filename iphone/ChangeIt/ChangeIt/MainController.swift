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
    
    override func viewWillLayoutSubviews()
    {
        var tabFrame = self.tabBar.frame
        // - 40 is editable , I think the default value is around 50 px, below lowers the tabbar and above increases the tab bar size
        tabFrame.size.height = 60
        tabFrame.origin.y = self.view.frame.size.height - 60
        self.tabBar.frame = tabFrame
        
    }
    
    func showLoginPage() {
        login = MyLogInViewController()
        login.fields = PFLogInFields.SignUpButton | PFLogInFields.LogInButton | PFLogInFields.Facebook | PFLogInFields.UsernameAndPassword
        login.delegate = self
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
        let itemsPage = navi.viewControllers[0] as! ItemsController
        itemsPage.loadData() { (results) -> Void in
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        if (PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!)) {
            loginFB()
        } else {
            addUser()
        }
        
        startItemsPage()
        
        login.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addUser() {
        let userId = PFUser.currentUser()!.objectId
        let name = PFUser.currentUser()?.username
        let userFromCloud = PFCloud.callFunction("getUser", withParameters: ["userId": userId!])
        let userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        if userJSON.count == 0 {
            PFCloud.callFunction("addUser", withParameters: ["name": name!, "objectId": userId!, "facebookId": ""])
        } else {
            PFCloud.callFunction("updateUser", withParameters: ["name": name!, "objectId": userId!, "facebookId": "", "location": ""])
        }
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
                    
                    let userFromCloud = PFCloud.callFunction("getUser", withParameters: ["userId": user.objectId!])
                    let userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                    if userJSON.count == 0 {
                        PFCloud.callFunction("addUser", withParameters: ["name": name, "objectId": user.objectId!, "facebookId": facebookId])
                        
                    } else {
                        PFCloud.callFunction("updateUser", withParameters: ["name": name, "objectId": user.objectId!, "facebookId": facebookId, "location": location])
                    }
                }
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
            }
        })
        
    }
}