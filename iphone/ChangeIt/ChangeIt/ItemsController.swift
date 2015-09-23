//
//  ItemsController.swift
//  ChangeIt
//
//  Created by i818292 on 5/4/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class ItemsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    var bookmarkMode:Bool = false
    var itemsJSON:JSON = nil
    var filteredItems:JSON = JSON("{}")
    var searchQuery:String!
    
    // pagination
    let ITEMS_PER_PAGE:Int = 3
    var currentPageNumber = 1
    var isPageRefreshing:Bool = false;
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var scopeButton: UIButton!
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        println("cancel")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        //self.searchDisplayController!.searchResultsTableView.rowHeight = tableView.rowHeight;
        //self.searchDisplayController!.searchBar.selectedScopeButtonIndex = 1
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let s = self.searchQuery {
        } else {
            return
        }
        if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
            println("currentPageNumber:\(currentPageNumber)")
            if (isPageRefreshing == false){
                isPageRefreshing = true;
                if (self.searchQuery == "nearMe") {
                    self.getNearMeItems(self.currentPageNumber++ * ITEMS_PER_PAGE) { (results) -> Void in
                        self.isPageRefreshing = false
                    }
                } else {
                    self.loadDataByFunction(self.searchQuery, limit: self.currentPageNumber++ * ITEMS_PER_PAGE) { (results) -> Void in
                        self.isPageRefreshing = false
                    }
                }
            }
        }
    }

    func loadDataByFunction(query:String, limit:Int, complete:(results:JSON) -> Void) {
        PFCloud.callFunctionInBackground(query, withParameters: ["search": ".*", "userId": (PFUser.currentUser()?.objectId)!, "limit": limit], block:{
            (items:AnyObject?, error: NSError?) -> Void in
            if (items == nil) {
                self.itemsJSON = JSON([])
                complete(results:self.itemsJSON)
                return
            }
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
            complete(results:self.itemsJSON)
        })
    }

    // Only used when load first time
    func loadData(complete:(results:JSON) -> Void) {
        // if no wish list, show all items. Otherwise, show best matched items.
        var wishesJSON:JSON!
        print("userId:\(PFUser.currentUser()?.objectId)")
        PFCloud.callFunctionInBackground("getWishesOfUser", withParameters: ["userId":(PFUser.currentUser()?.objectId)!], block: {
            (wishes:AnyObject?, error: NSError?) -> Void in
            if (wishes == nil) {
                return
            }
            let wishesJSON = JSON(data:(wishes as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            if (wishesJSON.count == 0) {
                self.getAllItemsExceptMe(self.ITEMS_PER_PAGE)
            } else {
                self.getBestItemsExceptMe(self.ITEMS_PER_PAGE)
            }
        })
    }
    
    func getAllItemsExceptMe(limit:Int) {
        searchQuery = "getAllItemsExceptMe"
        scopeButton.setTitle("All Items", forState:.Normal)
        self.loadDataByFunction(searchQuery, limit:limit) { (results) -> Void in
        }
    }
    
    func getBestItemsExceptMe(limit:Int) {
        searchQuery = "getBestItemsExceptMe"
        scopeButton.setTitle("Best Match", forState:.Normal)
        self.loadDataByFunction(searchQuery, limit:limit) { (results) -> Void in
            if (results.count == 0) {
                self.getAllItemsExceptMe(limit)
            }
        }
    }
    
    func getNearMeItems(limit:Int, complete:(results:JSON) -> Void) {
        searchQuery = "nearMe"
        scopeButton.setTitle("Near Me", forState:.Normal)
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint, error) -> Void in
            let query = PFQuery(className:"Item").whereKey("currentLocation", nearGeoPoint: geoPoint!, withinMiles: Double(limit))
            query.findObjectsInBackgroundWithBlock({
                (results, error) -> Void in
                if let items = results as? [PFObject] {
                    var total:[JSON] = []
                    for item in items {
                        let itemId = item["neo4jId"] as! String
                        var itemResult = PFCloud.callFunction("getItemExceptMe", withParameters: ["itemId": itemId, "userId": (PFUser.currentUser()?.objectId)!])
                        if (itemResult == nil) {
                            continue
                        }
                        var itemJSON = JSON(data:(itemResult as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                        total = total + itemJSON.arrayValue
                    }
                    self.itemsJSON = JSON(total)
                    self.tableView.reloadData()
                }
                
                complete(results:self.itemsJSON)
            })
        }
    }
    
    func loadAll(sender: AnyObject) {
        getAllItemsExceptMe(ITEMS_PER_PAGE)
    }
    
    func loadBest(sender: AnyObject) {
        getBestItemsExceptMe(ITEMS_PER_PAGE)
    }
    
    func loadNearMe(sender: AnyObject) {
        getNearMeItems(ITEMS_PER_PAGE) { (results) -> Void in
        }
    }
    
    @IBAction func pressed(sender: AnyObject) {
        let all = KxMenuItem("All Items", image:searchQuery == "getAllItemsExceptMe" ? UIImage(named:"check_icon") : nil, target:self, action:Selector("loadAll:"))
        let best = KxMenuItem("Best Match", image:searchQuery == "getBestItemsExceptMe" ? UIImage(named:"check_icon") : nil, target:self, action:Selector("loadBest:"))
        let location = KxMenuItem("Near Me", image:searchQuery == "nearMe" ? UIImage(named:"check_icon") : nil, target:self, action:Selector("loadNearMe:"))
        KxMenu.showMenuInView(self.view,
            fromRect:sender.frame,
            menuItems:[all, best, location]);
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scopes = self.searchDisplayController!.searchBar.scopeButtonTitles as! [String]
        let selectedScope = scopes[self.searchDisplayController!.searchBar.selectedScopeButtonIndex] as String
        loadDataByFunction(getQuery(selectedScope), limit:ITEMS_PER_PAGE) { (results) -> Void in
        }
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("itemDetail", sender: tableView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemsJSON == nil {
            return 0
        }
//        if tableView == self.searchDisplayController!.searchResultsTableView {
//            return self.filteredItems.count
//        } else {
//            return self.itemsJSON.count
//        }
        return self.itemsJSON.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("item") as! UITableViewCell
//        let itemJSON = (tableView == self.searchDisplayController!.searchResultsTableView) ? filteredItems[indexPath.row] : itemsJSON[indexPath.row]
        let itemJSON = itemsJSON[indexPath.row]
        PFQuery(className:"Image").getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            if let imageFile = imageObj!["file"] as? PFFile {
                let imageData = imageFile.getData()
                let itemImage = cell.viewWithTag(101) as! UIImageView
                itemImage.image = UIImage(data: imageData!)
            }
        })
        
        let itemLabel = cell.viewWithTag(102) as! UILabel
        itemLabel.text = itemJSON["title"].string
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "cancel") {
            return
        }
        var itemJSON:JSON = nil
        let tableView = sender as! UITableView
//        if tableView == self.searchDisplayController!.searchResultsTableView {
//            itemJSON = filteredItems[(tableView.indexPathForSelectedRow()?.row)!]
//        } else {
            itemJSON = itemsJSON[(tableView.indexPathForSelectedRow()?.row)!]
//        }

        // get user info based on item
        PFCloud.callFunctionInBackground("getUserOfItem", withParameters: ["itemId":(itemJSON["objectId"].string)!], block:{
            (user:AnyObject?, error: NSError?) -> Void in
            let userJSON = JSON(data:(user as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            
            let navi = segue.destinationViewController as! UINavigationController
            let detail = navi.topViewController as! ItemDetailController
            detail.userJSON = userJSON[0]
            detail.itemJSON = itemJSON
            detail.loadData(false)
        })
    }
}
