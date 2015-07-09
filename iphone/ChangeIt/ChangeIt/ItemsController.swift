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
    @IBOutlet var filterButton: UIButton!
    var bookmarkMode:Bool = false
    var itemsJSON:JSON = nil
    var filteredItems:JSON = JSON("{}")
    var searchModel:Int = 1
    @IBOutlet weak var scopeButton: UIButton!
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        println("cancel")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchDisplayController!.searchResultsTableView.rowHeight = tableView.rowHeight;
        //self.searchDisplayController!.searchBar.selectedScopeButtonIndex = 1
        
        self.filterButton.hidden = bookmarkMode
    }
    
    func loadData() {
        // if no wish list, show all items. Otherwise, show best matched items.
        var wishesJSON:JSON!
        PFCloud.callFunctionInBackground("getWishesOfUser", withParameters: ["userId":(PFUser.currentUser()?.objectId)!], block: {
            (wishes:AnyObject?, error: NSError?) -> Void in
            let wishesJSON = JSON(data:(wishes as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if (wishesJSON.count == 0) {
                self.loadData("getAllItemsExceptMe")
            } else {
                self.loadData("getBestItemsExceptMe")
            }
        })
    }
    
    func loadAll(sender: AnyObject) {
        searchModel = 0
        scopeButton.setTitle("All Items", forState:.Normal)
        self.itemsJSON = JSON("{}")
        self.loadData("getAllItemsExceptMe")
    }
    
    func loadBest(sender: AnyObject) {
        searchModel = 1
        scopeButton.setTitle("Best Match", forState:.Normal)
        self.itemsJSON = JSON("{}")
        self.loadData("getBestItemsExceptMe")
    }
    
    func loadNearMe(sender: AnyObject) {
        searchModel = 2
        scopeButton.setTitle("Near Me", forState:.Normal)
        self.itemsJSON = JSON("{}")
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint, error) -> Void in
            let query = PFQuery(className:"Item").whereKey("currentLocation", nearGeoPoint: geoPoint!, withinMiles: 10.0)
            query.findObjectsInBackgroundWithBlock({
                (results, error) -> Void in
                if let items = results as? [PFObject] {
                    var total:[JSON] = []
                    for item in items {
                        let itemId = item["neo4jId"] as! String
                        // TODO: how to wait for async callback then reload table
//                        PFCloud.callFunctionInBackground("getItem", withParameters: ["itemId": itemId], block:{
//                            (items:AnyObject?, error: NSError?) -> Void in
//                            var itemJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//                            total = total + itemJSON.arrayValue
//                            self.itemsJSON = JSON(total)
//                            self.tableView.reloadData()
//                        })
                        var itemResult = PFCloud.callFunction("getItem", withParameters: ["itemId": itemId])
                        var itemJSON = JSON(data:(itemResult as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                        total = total + itemJSON.arrayValue
                    }
                    self.itemsJSON = JSON(total)
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    @IBAction func pressed(sender: AnyObject) {
        let all = KxMenuItem("All Items", image:searchModel == 0 ? UIImage(named:"check_icon") : nil, target:self, action:Selector("loadAll:"))
        let best = KxMenuItem("Best Match", image:searchModel == 1 ? UIImage(named:"check_icon") : nil, target:self, action:Selector("loadBest:"))
        let location = KxMenuItem("Near Me", image:searchModel == 2 ? UIImage(named:"check_icon") : nil, target:self, action:Selector("loadNearMe:"))
        KxMenu.showMenuInView(self.view,
            fromRect:sender.frame,
            menuItems:[all, best, location]);
    }
    
    func loadData(query:String) {
        PFCloud.callFunctionInBackground(query, withParameters: ["search": ".*", "userId": (PFUser.currentUser()?.objectId)!], block:{
            (items:AnyObject?, error: NSError?) -> Void in
            if (items == nil) {
                self.itemsJSON = JSON("{}")
                return
            }
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
        })
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scopes = self.searchDisplayController!.searchBar.scopeButtonTitles as! [String]
        let selectedScope = scopes[self.searchDisplayController!.searchBar.selectedScopeButtonIndex] as String
        loadData(getQuery(selectedScope))
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        let scopes = self.searchDisplayController!.searchBar.scopeButtonTitles as! [String]
        let selectedScope = scopes[self.searchDisplayController!.searchBar.selectedScopeButtonIndex] as String
        self.filterContentForSearchText(searchString, scope: selectedScope)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        let scopes = self.searchDisplayController!.searchBar.scopeButtonTitles as! [String]
        let searchString = self.searchDisplayController!.searchBar.text.isEmpty ? ".*" : self.searchDisplayController!.searchBar.text
        self.filterContentForSearchText(searchString, scope: scopes[searchOption])
        return true
    }

    func getQuery(scope:String)->String {
        if (scope == "All") {
            return "getAllItemsExceptMe"
        } else if (scope == "Best Matched") {
            return "getBestItemsExceptMe"
        } else {
            
        }
        return "getAllItemsExceptMe"
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        PFCloud.callFunctionInBackground(getQuery(scope), withParameters: ["search": searchText, "userId": (PFUser.currentUser()?.objectId)!], block:{
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
        
        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            let imageData = (imageObj!["file"] as! PFFile).getData()
            cell.itemImage.image = UIImage(data: imageData!)
        })
        cell.itemLabel.text = itemJSON["title"].string
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "cancel") {
            return
        }
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
