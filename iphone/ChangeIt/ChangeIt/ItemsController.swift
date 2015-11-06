//
//  ItemsController.swift
//  ChangeIt
//
//  Created by i818292 on 5/4/15.
//  Copyright (c) 2015 i818292. All rights reserved.
//

import UIKit
import Parse

class ItemsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    var bookmarkMode:Bool = false
    var itemsJSON:JSON!
    var filteredItems:JSON = JSON("{}")
    var searchQuery:String!
    
    var searchController = UISearchController()
    var isDataFiltered:Bool = false
    
    // pagination
    let ITEMS_PER_PAGE:Int = 8
    var currentPageNumber = 1
    var isPageRefreshing:Bool = false;
    
    var imagesCache = [String:UIImage]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarContainer: UIView!
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        if (bookmarkMode == false) {
        }
        print("cancel")
    }
    
    @IBAction func saveSettings(segue:UIStoryboardSegue) {
        loadData() { (results) -> Void in
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (bookmarkMode == false) {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        searchController = ({
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.showsCancelButton = false // not working
            
            // without this, filtered data show black screen
            self.definesPresentationContext  = true
            
            //setup the search bar
//            searchController.searchBar.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
//            self.searchBarContainer?.addSubview(searchController.searchBar)
//            searchController.searchBar.sizeToFit()
            
            self.navigationItem.titleView = searchController.searchBar
//            self.tableView.tableHeaderView = searchController.searchBar
            searchController.searchBar.sizeToFit()
            
            return searchController
        })()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.bookmarkMode == true) {
            self.searchController.searchBar.hidden = true
            self.loadDataByFunction("getBookmarkedItems", limit:self.ITEMS_PER_PAGE) { (results) -> Void in
            }
        } else {
            loadData() { (results) -> Void in
            }
        }
    }
    
    // from UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        if searchText.isEmpty {
            isDataFiltered = false
            self.tableView.reloadData()
        } else {            
            getNearMeItems(searchText, limit:ITEMS_PER_PAGE) { (results) -> Void in
                self.filteredItems = results
                self.isDataFiltered = true
                self.tableView.reloadData()
            }
//            PFCloud.callFunctionInBackground(getQuery("All"), withParameters: ["search": searchText, "userId": (PFUser.currentUser()?.objectId)!, "limit": ITEMS_PER_PAGE], block:{
//                (results:AnyObject?, error: NSError?) -> Void in
//            if let error = error {
//                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
//                return
//            }
//                if (results == nil) {
//                    self.filteredItems = JSON("{}")
//                    return
//                }
//                self.filteredItems = JSON(data:(results as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//                self.isDataFiltered = true
//                self.tableView.reloadData()
//            })
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let _ = self.searchQuery {
        } else {
            return
        }
        if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) / 2) {
            print("currentPageNumber:\(currentPageNumber)")
            if (isPageRefreshing == false){
                isPageRefreshing = true;
                if (self.searchQuery == "nearMe") {
                    self.getNearMeItems(".*", limit: self.currentPageNumber++ * ITEMS_PER_PAGE) { (results) -> Void in
                        self.itemsJSON = results
                        self.tableView.reloadData()
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
        let spinner = createSpinner(self.view)
        PFCloud.callFunctionInBackground(query, withParameters: ["search": ".*", "userId": (PFUser.currentUser()?.objectId)!, "limit": limit], block:{
            (items:AnyObject?, error: NSError?) -> Void in
            if let error = error {
                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                spinner.stopAnimating()
                return
            }
            if (items == nil) {
                self.itemsJSON = JSON([])
                complete(results:self.itemsJSON)
                spinner.stopAnimating()
                return
            }
            self.itemsJSON = JSON(data:(items as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
            self.tableView.reloadData()
            spinner.stopAnimating()
            complete(results:self.itemsJSON)
        })
    }

    // Only used when load first time
    func loadData(complete:(results:JSON) -> Void) {
        // if no wish list, show all items. Otherwise, show best matched items.
//        var wishesJSON:JSON!
        print("userId:\(PFUser.currentUser()?.objectId)")
        
        //self.getAllItemsExceptMe(self.ITEMS_PER_PAGE)
        self.getAllItemsNearMe(self.ITEMS_PER_PAGE)
        // TODO: first version, don't show items by wish
//        PFCloud.callFunctionInBackground("getWishesOfUser", withParameters: ["userId":(PFUser.currentUser()?.objectId)!], block: {
//            (wishes:AnyObject?, error: NSError?) -> Void in
//            if (wishes == nil) {
//                return
//            }
//            let wishesJSON = JSON(data:(wishes as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
//            if (wishesJSON.count == 0) {
//                self.getAllItemsExceptMe(self.ITEMS_PER_PAGE)
//            } else {
//                self.getBestItemsExceptMe(self.ITEMS_PER_PAGE)
//            }
//        })
    }
    
    func getAllItemsExceptMe(limit:Int) {
        searchQuery = "getAllItemsExceptMe"
        self.loadDataByFunction(searchQuery, limit:limit) { (results) -> Void in
        }
    }
    
    func getBestItemsExceptMe(limit:Int) {
        searchQuery = "getBestItemsExceptMe"
        self.loadDataByFunction(searchQuery, limit:limit) { (results) -> Void in
            if (results.count == 0) {
                self.getAllItemsExceptMe(limit)
            }
        }
    }
    
    func getAllItemsNearMe(limit:Int) {
        searchQuery = "nearMe"
        self.getNearMeItems(".*", limit:limit) { (results) -> Void in
            self.itemsJSON = results
            self.tableView.reloadData()
        }
    }
    
    func getNearMeItems(searchText:String, limit:Int, complete:(results:JSON) -> Void) {
        let spinner = createSpinner(self.view)
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint, error) -> Void in

            PFCloud.callFunctionInBackground("getUser", withParameters: ["userId": (PFUser.currentUser()!.objectId)!], block:{
                (userFromCloud:AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                    spinner.stopAnimating()
                    return
                }

                let userJSON = JSON(data:(userFromCloud as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)[0]
                
                // reset back all when reach 100 miles
                let distance = userJSON["distance"].doubleValue == 100 ? 0 : userJSON["distance"].doubleValue
                print("distance:\(distance)")
                let query = PFQuery(className:"Item").whereKey("currentLocation", nearGeoPoint: geoPoint!, withinMiles: distance)
                query.cachePolicy = .CacheElseNetwork
                query.findObjectsInBackgroundWithBlock({
                    (results, error) -> Void in
                    if let items = results as? [PFObject] {
                        var ids:[String] = []
                        for item in items {
                            let itemId = item["neo4jId"] as! String
                            ids.append(itemId)
                        }
                        
                        NSLog("ids:\(ids)")
                        
                        PFCloud.callFunctionInBackground("getItemsByList", withParameters: ["search": searchText, "ids": ids, "userId": (PFUser.currentUser()?.objectId)!, "limit":limit], block: { (itemResult, error) -> Void in
                            if let error = error {
                                NSLog("Error: \(error.localizedDescription), UserInfo: \(error.localizedDescription)")
                                spinner.stopAnimating()
                                return
                            }
                            if (itemResult == nil) {
                                complete(results:JSON([]))
                                spinner.stopAnimating()
                                return
                            }
                            let results = JSON(data:(itemResult as! NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
                            complete(results:results)
                            spinner.stopAnimating()
                        })
                    }
                })
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
        getAllItemsNearMe(ITEMS_PER_PAGE)
    }
    
    @IBAction func pressed(sender: AnyObject) {
    }
    
    func getQuery(scope:String)->String {
//        if (scope == "All") {
//            return "getAllItemsExceptMe"
//        } else if (scope == "Best Matched") {
//            return "getBestItemsExceptMe"
//        } else {
//        }
        return "getAllItemsExceptMe"
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
        if (self.isDataFiltered) {
            return self.filteredItems.count
        }
        if let _ = self.itemsJSON {
            if (self.itemsJSON.count == 0 && bookmarkMode == false) {
                return 1
            }
            return self.itemsJSON.count
        }
        return 0
    }
    
    func lazyLoading(itemJSON:JSON, indexPath:NSIndexPath, cell:UITableViewCell) {
        if let _ = itemJSON["objectId"].string {
            if let _ = self.imagesCache[itemJSON["objectId"].string!] {
                return
            }
        } else {
            return
        }
        
        let itemImage = cell.viewWithTag(101) as! UIImageView
        createImageQuery().getObjectInBackgroundWithId(itemJSON["photo"].string!, block: {
            (imageObj:PFObject?, error: NSError?) -> Void in
            if let _ = imageObj {
                if let imageFile = imageObj!["file"] as? PFFile {
                    if let imageData = imageFile.getData() {
                        itemImage.image = UIImage(data: imageData)
                        
                        // cache the image for later render
                        self.imagesCache[itemJSON["objectId"].string!] = itemImage.image
                        
                        if (itemImage.subviews.count == 0) {
                            let overlay = UIView(frame: itemImage.frame)
                            overlay.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.35)
                            itemImage.addSubview(overlay)
                        }
                    }
                }
            }
        })
    }
    
    func lazyLoadingOnScreenRows() {
        let visiblePaths = self.tableView.indexPathsForVisibleRows
        for indexPath in visiblePaths! {
            let itemJSON = self.isDataFiltered ? filteredItems[indexPath.row] : itemsJSON[indexPath.row]["item"]
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            lazyLoading(itemJSON, indexPath:indexPath, cell:cell!)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (decelerate == false) {
            lazyLoadingOnScreenRows()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        lazyLoadingOnScreenRows()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.itemsJSON.count == 0) {
            return self.tableView.dequeueReusableCellWithIdentifier("noData", forIndexPath: indexPath)
        }
        
        print(indexPath.row)
        let cell = self.tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath)
        var itemJSON = self.isDataFiltered ? filteredItems[indexPath.row] : itemsJSON[indexPath.row]["item"]
        
        let itemImage = cell.viewWithTag(101) as! UIImageView
        let itemLabel = cell.viewWithTag(102) as! UILabel
        itemLabel.text = itemJSON["title"].string
        
        // lazy loading
        if let image = imagesCache[itemJSON["objectId"].string!] {
            itemImage.image = image
        } else {
            if (self.tableView.dragging == false && self.tableView.decelerating == false) {
                self.lazyLoading(itemJSON, indexPath:indexPath, cell:cell)
            }
            itemImage.image = nil
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "cancel" || segue.identifier == "settings") {
            return
        }
        
        var itemInfoJSON:JSON = nil
        let tableView = sender as! UITableView
        if self.isDataFiltered {
            itemInfoJSON = filteredItems[(tableView.indexPathForSelectedRow?.row)!]
        } else {
            itemInfoJSON = itemsJSON[(tableView.indexPathForSelectedRow?.row)!]
        }

        let detail = segue.destinationViewController as! ItemDetailController
        detail.userJSON = itemInfoJSON["user"]
        detail.itemJSON = itemInfoJSON["item"]
        detail.loadData()
    }
}
