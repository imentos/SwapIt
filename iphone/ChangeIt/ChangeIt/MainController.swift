import UIKit

class MainController: UITabBarController {
    
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
}