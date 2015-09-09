import UIKit
import Parse
import ParseUI

class MainController: UITabBarController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    var login:MyLogInViewController!
    var unwindFromUser:Bool = false
    override func viewDidAppear(animated: Bool) {
        if (self.unwindFromUser) {
            return
        }
        
        // check user login
        if let user = PFUser.currentUser() {
            startItemsPage()
        } else {
            login = MyLogInViewController()
            login.fields = PFLogInFields.SignUpButton | PFLogInFields.LogInButton | PFLogInFields.Facebook | PFLogInFields.UsernameAndPassword
            login.delegate = self
            login.signUpController?.delegate = self
            self.presentViewController(login, animated: true, completion: { () -> Void in
                //
            })
        }
    }
    
    // from user
    @IBAction func cancel(segue:UIStoryboardSegue) {
        self.unwindFromUser = true
    }
    
    @IBAction func addItem(segue:UIStoryboardSegue) {
        self.selectedIndex = 1
    }

    @IBAction func cancelItem(segue:UIStoryboardSegue) {
        self.selectedIndex = 1
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
        itemsPage.loadData()
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