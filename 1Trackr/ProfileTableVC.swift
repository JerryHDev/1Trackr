//
//  ProfileTableVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/26/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit
import Parse

class ProfileTableVC: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //Initialize variables
    var name: String!
    var internship: String!
    var email: String!
    var totalHours: String!
    var totalVerifiedMins = 0
    
    // Profile pic file and image
    var imageFile: PFFile!
    var tempImage: UIImage!
    
    
    var refresher: UIRefreshControl!
    
    // Activity indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

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
    
    
    // User pressed profile picture
    @IBAction func chooseImage(sender: AnyObject) {
        
        let actionSheetController = UIAlertController(title: "Change profile picture", message: "", preferredStyle: .ActionSheet)
        
        
        // Remove current photo action
        let deleteAction = UIAlertAction(title: "Delete current photo", style: UIAlertActionStyle.Destructive) { (ACTION) -> Void in
            
            // Starts activity indicator
            let container: UIView = UIView()
            container.frame = self.view.frame
            container.center = self.view.center
            container.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.3)
            let loadingView: UIView = UIView()
            loadingView.frame = CGRectMake(0, 0, 80, 80)
            loadingView.center = self.view.center
            loadingView.backgroundColor = UIColor(red: 68/255.0, green: 68/255.0, blue: 68/255.0, alpha: 0.7)
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
            activityIndicator.activityIndicatorViewStyle =
                UIActivityIndicatorViewStyle.WhiteLarge
            activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2,
                loadingView.frame.size.height / 2);
            activityIndicator.hidesWhenStopped = true
            loadingView.addSubview(activityIndicator)
            container.addSubview(loadingView)
            self.view.addSubview(container)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            let profileQuery = PFQuery(className: "_User")
            profileQuery.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) {
                (user: PFObject?, error: NSError?) -> Void in
                
                if error == nil {
                    if let user = user {
                        
                        // Sets default user profile pic
                        let profilePic = UIImage(named: "defaultProfilePic")
                        self.tempImage = profilePic
                        self.tableView.reloadData()
                        let imageData = UIImagePNGRepresentation(profilePic!)
                        let imageFile = PFFile(name: "image.jpg", data: imageData!)
                        user["profilePic"] = imageFile
                        user.saveInBackgroundWithBlock({ (success, error) -> Void in
                            
                            if error == nil {
                                // Stops activity indicator
                                self.activityIndicator.stopAnimating()
                                loadingView.removeFromSuperview()
                                container.removeFromSuperview()
                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                print("Successfully deleted profile pic")
                            } else {
                                // Stops activity indicator
                                self.activityIndicator.stopAnimating()
                                loadingView.removeFromSuperview()
                                container.removeFromSuperview()
                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                self.displayAlert("Error", message: "Could not delete profile image. Try again later!")
                            }
                        })
                    }
                } else {
                    // Stops activity indicator
                    self.activityIndicator.stopAnimating()
                    loadingView.removeFromSuperview()
                    container.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.displayAlert("Error", message: "Could not delete profile image. Try again later!")
                }
            }
        }
        
        
        // Choose photo from library action
        let chooseAction = UIAlertAction(title: "Choose from library", style: UIAlertActionStyle.Default) { (ACTION) -> Void in
            
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            image.allowsEditing = false
            self.presentViewController(image, animated: true, completion: nil)
        }
        
        // Take photo action
        let takeAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default) { (ACTION) -> Void in
            
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(image, animated: true, completion: nil)
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (ACTION) -> Void in
        }
        
    
        // Add actions to action sheet
        actionSheetController.addAction(deleteAction)
        actionSheetController.addAction(chooseAction)
        actionSheetController.addAction(takeAction)
        actionSheetController.addAction(cancelAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        tempImage = image
        self.tableView.reloadData()
        postImage()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /** Updates profile image onto Parse.com */
    func postImage() {
        // Starts activity indicator
        let container: UIView = UIView()
        container.frame = view.frame
        container.center = view.center
        container.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.3)
        let loadingView: UIView = UIView()
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor(red: 68/255.0, green: 68/255.0, blue: 68/255.0, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2,
            loadingView.frame.size.height / 2);
        activityIndicator.hidesWhenStopped = true
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        view.addSubview(container)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let imageData = self.tempImage.highQualityJPEGNSData//UIImagePNGRepresentation(self.tempImage) //self.tempImage.lowQualityJPEGNSData
        let imageFile = PFFile(name: "image.jpg", data: imageData)
        imageFile.saveInBackground()
        
        // Sets new user profile picture
        let profileQuery = PFQuery(className: "_User")
        profileQuery.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) {
            (user: PFObject?, error: NSError?) -> Void in
            
            if error == nil {
                if let user = user {
                    
                    user["profilePic"] = imageFile
                    
                    user.saveInBackgroundWithBlock({ (success, error) -> Void in
                        
                        if error == nil {
                            // Stops activity indicator
                            self.activityIndicator.stopAnimating()
                            loadingView.removeFromSuperview()
                            container.removeFromSuperview()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            print("Successfully updated user profile picture!!!!")
                        } else {
                            // Stops activity indicator
                            self.activityIndicator.stopAnimating()
                            loadingView.removeFromSuperview()
                            container.removeFromSuperview()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            self.displayAlert("Error", message: "Could not save profile image. Try again later!")
                        }
                    })
                }
            } else {
                // Stops activity indicator
                self.activityIndicator.stopAnimating()
                loadingView.removeFromSuperview()
                container.removeFromSuperview()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.displayAlert("Error", message: "Could not change profile image. Try again later!")
            }
        }
    }
    
    
    /** Refresh user data on profile page */
    func refresh() {
        
        // Query for current user data with correct objectId
        let query: PFQuery = PFUser.query()!
        query.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) { (user, error) -> Void in
            
            if error == nil {
                if let user = user {
                    
                    self.name = user["fullName"] as? String
                    
                    self.internship = user["internship"] as? String
                    let internshipName = self.internship.removeWhitespace()
                    
                    let postQuery = PFQuery(className: internshipName)
                    postQuery.whereKey("userId", equalTo: (PFUser.currentUser()?.objectId)!)
                    postQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                        
                        if let objects = objects {
                            
                            self.totalVerifiedMins = 0
                            
                            for object in objects {
                                
                                if object["verified"] as! Bool == true {
                                    self.totalVerifiedMins += (object["addedMins"] as! Int)
                                }
                            }
                            self.tableView.reloadData()
                        } else {
                            self.displayAlert("Error", message: String(error))
                        }
                    })

                    
                    self.email = user["email"] as? String
                    let totalHours : String = self.minutesToHours(user["totalMins"] as! Int)
                    self.totalHours = totalHours
                    
                    // Download profile image file
                    self.imageFile = user["profilePic"] as! PFFile
                    self.imageFile.getDataInBackgroundWithBlock { (data, error) -> Void in
                        
                        if error == nil {
                            if let downloadedImage = UIImage(data: data!) {
                                // Sets profile image
                                self.tempImage = downloadedImage
                            }
                        }
                        self.tableView.reloadData()
                    }
                    
                    self.tableView.reloadData()
                    self.refresher.endRefreshing()
                } else {
                    // Log details of the failure
                    self.displayAlert("Error", message: "Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
    
    
    func minutesToHours(minutes: Int) -> String {
        
        let hours = Double(minutes) / 60.0
        
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter.stringFromNumber(hours)!
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
        return 5
    }

    /** Customizes each cell in table view */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let myCell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! ProfileCell
            myCell.nameLabel.text = name
            myCell.profilePic.image = tempImage
            myCell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
            return myCell
        } else if indexPath.row == 1 {
            let myCell = tableView.dequeueReusableCellWithIdentifier("infoCell", forIndexPath: indexPath) as! InfoCell
            myCell.titleLabel.text = "Email"
            myCell.detailLabel.text = email
            return myCell
        } else if indexPath.row == 2 {
            let myCell = tableView.dequeueReusableCellWithIdentifier("infoCell", forIndexPath: indexPath) as! InfoCell
            myCell.titleLabel.text = "Internship"
            myCell.detailLabel.text = internship
            myCell.detailLabel.font = UIFont(name: myCell.detailLabel.font.fontName, size: 12)
            return myCell
        } else if indexPath.row == 3 {
            let myCell = tableView.dequeueReusableCellWithIdentifier("infoCell", forIndexPath: indexPath) as! InfoCell
            myCell.titleLabel.text = "Total Hours"
            myCell.detailLabel.text = totalHours
            myCell.detailLabel.font = UIFont(name: myCell.detailLabel.font.fontName, size: 24)
            return myCell
        } else {
            let myCell = tableView.dequeueReusableCellWithIdentifier("infoCell", forIndexPath: indexPath) as! InfoCell
            myCell.titleLabel.text = "Total Verified Hours"
            myCell.titleLabel.textColor = UIColor(red: 59/255.0, green: 181/255.0, blue: 143/255.0, alpha: 1.0)
            myCell.detailLabel.text = minutesToHours(totalVerifiedMins)
            myCell.detailLabel.font = UIFont(name: myCell.detailLabel.font.fontName, size: 24)
            myCell.detailLabel.textColor = UIColor(red: 59/255.0, green: 181/255.0, blue: 143/255.0, alpha: 1.0)
            return myCell
        }
    }
    
    
    /** Customizes height of each cell in table view */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row > 0 {
            return 70
        }
        else {
            return 172
        }
    }
    
    
    /** Displays pop up alert */
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}

