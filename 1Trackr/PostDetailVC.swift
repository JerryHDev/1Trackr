//
//  PostDetailVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/31/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit
import Parse

class PostDetailVC: UIViewController,  UITextFieldDelegate, UITextViewDelegate {
    
    // Variable values will be set in prepareForSegue in HoursTableVC
    var minutes: String = ""
    var descriptionText: String = ""
    var objectId: String = ""
    var date: String = ""
    
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    // Initialize textfields
    @IBOutlet var minuteTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var dateSelectionTextField: UITextField!
    
    var datePicker: UIDatePicker!
    
    // Activity indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextViewTextDidChangeNotification, object: nil)
        saveButton.enabled = false
        
        dateSelectionTextField.text = date
        minuteTextField.text = minutes
        descriptionTextView.text = descriptionText
        
        // Adds tap recognition
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        self.minuteTextField.delegate = self
        self.descriptionTextView.delegate = self
    }
    
    
    /** Creates and customizes UI Date Picker */
    func createDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        dateSelectionTextField.inputView = datePicker
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 35.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.Default
        toolBar.tintColor = UIColor(red: 59/255.0, green: 181/255.0, blue: 143/255.0, alpha: 1.0)
        toolBar.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1.0)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "donePressed:")
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        label.font = UIFont(name: "Helvetica", size: 15)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor(red: 59/255.0, green: 181/255.0, blue: 143/255.0, alpha: 1.0)
        label.text = "Date"
        label.textAlignment = NSTextAlignment.Center
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexSpace, textBtn, flexSpace, doneButton], animated: true)
        dateSelectionTextField.inputAccessoryView = toolBar
    }
    
    
    /** Set the date in date selection text field */
    func donePressed(sender: UIBarButtonItem) {
        print(datePicker.date)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        self.dateSelectionTextField.text = strDate
        dateSelectionTextField.resignFirstResponder()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /** Edit hour post on Parse*/
    @IBAction func save(sender: AnyObject) {
        
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
        
        // Accesses the user
        let userQuery = PFQuery(className: "_User")
        userQuery.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) {
            (user: PFObject?, error: NSError?) -> Void in
            
            if error != nil {
                
                // Stops activity indicator
                self.activityIndicator.stopAnimating()
                loadingView.removeFromSuperview()
                container.removeFromSuperview()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                self.displayAlert("Error", message: String(error))
            } else if let user = user {
                
                // Get current user's internship
                let internship = user["internship"] as! String
                let internshipName = internship.removeWhitespace()
                
                // Query for the specific post
                let postQuery = PFQuery(className: internshipName)
                
                postQuery.getObjectInBackgroundWithId(self.objectId, block: { (object: PFObject?, error: NSError?) -> Void in
                    
                    
                    if error != nil {
                        print(error)
                    } else if let object = object {
                        
                        // Gets difference, then adds difference to user total hours
                        let difference: Int! = Int(self.minuteTextField.text!)! - (object["addedMins"] as! Int)
                        let currentMins: Int! = user["totalMins"] as! Int
                        let newMins = (currentMins + difference)
                        user["totalMins"] = newMins
                        user.saveInBackground()
                        
                        // Update post
                        object["description"] = self.descriptionTextView.text
                        object["addedMins"] = Int(self.minuteTextField.text!)
                        
                        object.saveInBackgroundWithBlock({ (success, ErrorType) -> Void in
                            if error == nil {
                                
                                // Stops activity indicator
                                self.activityIndicator.stopAnimating()
                                loadingView.removeFromSuperview()
                                container.removeFromSuperview()
                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                
                                print("Successfully changed post info!")
                                NSNotificationCenter.defaultCenter().postNotificationName("RefreshMasterNotification", object: nil)
                                self.dismissViewControllerAnimated(true, completion: nil)
                            } else {
                                
                                // Stops activity indicator
                                self.activityIndicator.stopAnimating()
                                loadingView.removeFromSuperview()
                                container.removeFromSuperview()
                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                
                                self.displayAlert("Error", message: "Could not edit the log. Try again later.")
                            }
                        })
                    }
                })
            }
        }
    }
    
    
    /** Deletes the selected hour post */
    @IBAction func deletePressed(sender: AnyObject) {
        
        let actionSheetController = UIAlertController(title: "", message: "Are you sure?", preferredStyle: .ActionSheet)
        
        // Delete post action
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive) { (ACTION) in
            
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
            
            let userQuery: PFQuery = PFUser.query()!
            userQuery.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) { (user, error) -> Void in
                
                if error == nil {
                    
                    // Gets user
                    if let user = user {
                        
                        // Get current user's internship
                        let internship = user["internship"] as! String
                        let internshipName = internship.removeWhitespace()
                        
                        // Gets specific hour post
                        let postQuery = PFQuery(className: internshipName)
                        
                        postQuery.getObjectInBackgroundWithId(self.objectId, block: { (object, error) -> Void in
                            
                            if error != nil {
                                self.displayAlert("Error", message: "Could not access post")
                            } else if let object = object {
                                
                                // Delete the post and post hour on user profile
                                let currentMins : Int! = user["totalMins"] as! Int
                                let postMins : Int! = object["addedMins"] as! Int
                                let newMins = currentMins - postMins
                                user["totalMins"] = newMins
                                user.saveInBackground()
                                
                                object.deleteInBackgroundWithBlock({ (success, error) -> Void in
                                    if error == nil {
                                        
                                        // Stops activity indicator
                                        self.activityIndicator.stopAnimating()
                                        loadingView.removeFromSuperview()
                                        container.removeFromSuperview()
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()

                                        
                                        print("Successfully deleted the post!!")
                                        NSNotificationCenter.defaultCenter().postNotificationName("RefreshMasterNotification", object: nil)
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    } else {
                                        
                                        // Stops activity indicator
                                        self.activityIndicator.stopAnimating()
                                        loadingView.removeFromSuperview()
                                        container.removeFromSuperview()
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                        
                                        self.displayAlert("Error", message: "Post could not be deleted!")
                                    }
                                })
                            }
                        })
                    }
                } else {
                    
                    // Stops activity indicator
                    self.activityIndicator.stopAnimating()
                    loadingView.removeFromSuperview()
                    container.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    // Log details of the failure
                    self.displayAlert("Error", message: "error: \(error!) \(error!.userInfo)")
                }
            }
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (ACTION) in
        }
        
        // Add actions to action sheet
        actionSheetController.addAction(deleteAction)
        actionSheetController.addAction(cancelAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    
    /** Save button enabled only when user has changed info */
    func textChanged(sender: NSNotification) {
        if minuteTextField.hasText() && descriptionTextView.hasText() {
            if (minuteTextField.text != minutes) || (descriptionTextView.text != descriptionText) {
                saveButton.enabled = true
            }
        }
        else {
            saveButton.enabled = false
        }
    }
    
    
    /** Controls text view for adding description */
    func textViewDidBeginEditing(descriptionTextView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGrayColor() {
            descriptionTextView.text = nil
            descriptionTextView.textColor = UIColor.blackColor()
        }
    }
    func textViewDidEndEditing(descriptionTextView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Short description of work..."
            descriptionTextView.textColor = UIColor.lightGrayColor()
        }
    }
    
    /** Displays pop up alert */
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    /** Keyboard dimisses when screen tapped */
    func DismissKeyboard() {
        view.endEditing(true)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}