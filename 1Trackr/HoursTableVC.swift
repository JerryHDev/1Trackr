//
//  HoursTableVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/14/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit
import Parse

class HoursTableVC: UITableViewController {
    
    
    // Initialize variables
    var descriptions = [String]()
    var minutes = [Int]()
    var objectIds = [String]()
    var dates = [String]()
    var verifiedList = [Bool]()
    
    var refresher: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hides the extra separator lines
        tableView.tableFooterView = UIView(frame:CGRectZero)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshNotified:", name: "RefreshMasterNotification", object: nil)
        
        refresher = UIRefreshControl()
        
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refresher)
        
        refresh()
    }
    
    func refreshNotified(sender: NSNotification) {
        refresh()
    }
    
    /** Refreshes all hour posts */
    func refresh() {
        
        // Accesses the user
        let query = PFQuery(className: "_User")
        query.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) {
            (updatedObject: PFObject?, error: NSError?) -> Void in
            
            if error != nil {
                print(error)
            } else if let updatedObject  = updatedObject {
                
                // Get current user's internship
                let internship = updatedObject["internship"] as! String
                let className = internship.removeWhitespace()
                
                // Queries for data from user's internship class
                let postQuery = PFQuery(className: className)
                postQuery.whereKey("userId", equalTo: PFUser.currentUser()!.objectId!)
                
                // Arrange by descending order
                postQuery.orderByDescending("createdAt")
                
                postQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                   
                    if let objects = objects {
                        
                        // refresh three arrays
                        self.descriptions.removeAll()
                        self.minutes.removeAll()
                        self.objectIds.removeAll()
                        self.verifiedList.removeAll()
                        self.dates.removeAll()
                        
                        for object in objects  {
                            
                            // Loop through posts and add info to arrays
                            self.descriptions.append(object["description"] as! String)
                            self.minutes.append(object["addedMins"] as! Int)
                            self.objectIds.append(String(object.valueForKey("objectId")!))
                            self.verifiedList.append(object["verified"] as! Bool)
                            self.dates.append(object["date"] as! String)
                        }
                        
                        // End refreshing and refresh the table view
                        self.refresher.endRefreshing()
                        self.tableView.reloadData()
                    } else {
                        self.displayAlert("Error", message: String(error))
                    }
                })
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return descriptions.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let postCell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! PostCell
    
        // Configure the cell...
        postCell.workDescription.text = descriptions[indexPath.row]
        postCell.minutes.text = "\(minutes[indexPath.row])"
        postCell.dateLabel.text = dates[indexPath.row]
        
        // If a post is verified, unhide the verified badge
        if verifiedList[indexPath.row] == false {
            postCell.verifiedBadge.hidden = true
            print("HIDING BADGE BECAUSE NO VERIFICATION")
        } else {
            postCell.verifiedBadge.hidden = false
            print("NOT HIDING BADGE, VERIFIED")
        }
        
        return postCell
    }
    
    /** Presents the Post Detail VC when a cell is selected */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        // MARK: - SECURITY FEATURE
        
        /** If a post has been verified, user cannot make any more changes to it */
        if verifiedList[indexPath.row] == false {
            print("This post has not been verified yet. Going to edit post now!!")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let detailController = storyBoard.instantiateViewControllerWithIdentifier("postDetailVC") as! PostDetailVC
            let navController = UINavigationController(rootViewController: detailController)
            detailController.minutes = "\(minutes[indexPath.row])"
            detailController.descriptionText = descriptions[indexPath.row]
            detailController.objectId = objectIds[indexPath.row]
            detailController.date = dates[indexPath.row]
            
            self.presentViewController(navController, animated:true, completion:nil)
        } else {
            
            self.displayAlert("Error", message: "This log has been verified by a site manager. No more changes to minutes or description on this post can be made!")
        }
        
    }
    
    /** Displays pop up alert */
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
