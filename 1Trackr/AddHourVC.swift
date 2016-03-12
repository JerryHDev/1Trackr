//
//  AddHoursVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/14/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit
import Parse

class AddHoursVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet var createButton: UIBarButtonItem!
    
    // Initialize text fields
    @IBOutlet var minuteTextField: UITextField!
    @IBOutlet var dateSelectionTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    
    var datePicker: UIDatePicker!
    
    // Activity indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create date picker
        createDatePicker()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextViewTextDidChangeNotification, object: nil)
        createButton.enabled = false
        
        descriptionTextView.text = "Add a short description of work..."
        descriptionTextView.textColor = UIColor.lightGrayColor()
        
        // Adds tap recognition
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        self.minuteTextField.delegate = self
        self.dateSelectionTextField.delegate = self
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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        self.dateSelectionTextField.text = strDate
        dateSelectionTextField.resignFirstResponder()
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /** Adds hours on to Parse */
    @IBAction func addHours(sender: AnyObject) {
        
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
        
        
        // Adds hours to current user's profile
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
                
                // update total user minutes
                let currentMins : Int! = user["totalMins"] as! Int
                let newMins = (currentMins + Int(self.minuteTextField.text!)!)
                user["totalMins"] = newMins
                
                // get current user's internship
                let internship = user["internship"] as! String
                let internshipName = internship.removeWhitespace()
                
                // Creates hours post for internship on Parse
                let post = PFObject(className: internshipName)
                
                post["description"] = self.descriptionTextView.text
                post["userId"] = PFUser.currentUser()!.objectId!
                post["addedMins"] = Int(self.minuteTextField.text!)!
                post["date"] = self.dateSelectionTextField.text
                post["name"] = user["fullName"]
                post["verified"] = false
                
                user.saveInBackground()
                
                post.saveInBackgroundWithBlock{(success, error) -> Void in
                    if error == nil {
                        
                        // Stops activity indicator
                        self.activityIndicator.stopAnimating()
                        loadingView.removeFromSuperview()
                        container.removeFromSuperview()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("RefreshMasterNotification", object: nil)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        
                        // Stops activity indicator
                        self.activityIndicator.stopAnimating()
                        loadingView.removeFromSuperview()
                        container.removeFromSuperview()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()

                        self.displayAlert("Error", message: "Could not log hour. Try again later!")
                    }
                }
            }
        }
    }
    
    
    /** Save button enabled only when user has entered all info */
    func textChanged(sender: NSNotification) {
        if (minuteTextField.hasText() && descriptionTextView.text != "Add a short description of work...") && (dateSelectionTextField.hasText()) {
            createButton.enabled = true
        } else {
            createButton.enabled = false
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
            descriptionTextView.text = "Add a short description of work..."
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


/** Extension: - removes whitespaces from string */
extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
    
}
