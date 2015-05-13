//
//  ItemsController.swift
//  ChangeIt
//
//  Created by i818292 on 5/4/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class ItemsController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    var itemsJSON:JSON = nil
    var filteredItems:JSON = JSON("{}")
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        println("cancel")
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchDisplayController!.searchResultsTableView.rowHeight = tableView.rowHeight;
        self.searchDisplayController!.searchBar.selectedScopeButtonIndex = 1

        loadData()
    }
    
    func loadData() {
        if PFUser.currentUser() == nil {
            return
        }
        
        PFCloud.callFunctionInBackground("getAllItemsExceptMe", withParameters: ["search": ".*", "userId": (PFUser.currentUser()?.objectId)!], block:{
            (items:AnyObject?, error: NSError?) -> Void in
            if (items == nil) {
                self.itemsJSON = JSON("{}")
                return
            }
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        let scopes = self.searchDisplayController!.searchBar.scopeButtonTitles as! [String]
        let selectedScope = scopes[self.searchDisplayController!.searchBar.selectedScopeButtonIndex] as String
        self.filterContentForSearchText(searchString, scope: selectedScope)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        let scopes = self.searchDisplayController!.searchBar.scopeButtonTitles as! [String]
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text, scope: scopes[searchOption])
        return true
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        var query:String = "getAllItemsExceptMe"
        if (scope == "All") {
            query = "getAllItemsExceptMe"
        } else if (scope == "Best Matched") {
            query = "getBestItemsExceptMe"
        } else {
            
        }

        PFCloud.callFunctionInBackground(query, withParameters: ["search": searchText, "userId": (PFUser.currentUser()?.objectId)!], block:{
            (results:AnyObject?, error: NSError?) -> Void in
            if (results == nil) {
                self.filteredItems = JSON("{}")
                return
            }
            self.filteredItems = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.searchDisplayController?.searchResultsTableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("itemDetail", sender: tableView)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemsJSON == nil {
            return 0
        }
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredItems.count
        } else {
            return self.itemsJSON.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("ItemCell") as! ItemCell!
        if !(cell != nil) {
            cell = ItemCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ItemCell")
        }
        let itemJSON = (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredItems[indexPath.row] : itemsJSON[indexPath.row]
        println(itemJSON["photo"].string)
        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            if (imageObj == nil) {
                return
            }
            let imageData = (imageObj!["file"] as! PFFile).getData()
            cell.itemImage.image = UIImage(data: imageData!)
        })
        cell.itemLabel.text = itemJSON["title"].string
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var itemJSON:JSON = nil
        let tableView = sender as! UITableView
        if tableView == self.searchDisplayController!.searchResultsTableView {
            itemJSON = filteredItems[(tableView.indexPathForSelectedRow()?.row)!]
        } else {
            itemJSON = itemsJSON[(tableView.indexPathForSelectedRow()?.row)!]
        }

        // get user info based on item
        PFCloud.callFunctionInBackground("getUserOfItem", withParameters: ["itemId":(itemJSON["objectId"].string)!], block:{
            (user:AnyObject?, error: NSError?) -> Void in
            let userJSON = JSON(data:(user as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            
            let navi = segue.destinationViewController as! UINavigationController
            let detail = navi.childViewControllers[0] as! ItemDetailController
            detail.userJSON = userJSON[0]
            detail.itemJSON = itemJSON
            detail.loadData()
        })
    }
}
