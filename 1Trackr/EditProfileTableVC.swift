//
//  EditProfileTableVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/27/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit
import Parse

class EditProfileTableVC: UITableViewController, UITextFieldDelegate {
    
    
    // Initialize textfield variables
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var email: UITextField!
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    // Activity indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        
        // Detects when text in textfield is changed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        doneButton.enabled = false
        
        
        getUserProfile()
        
        // Adds tap recognition
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        self.firstName.delegate = self
        self.lastName.delegate = self
        self.email.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /** Gets user info from Parse.com */
    func getUserProfile() {
        
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
        
        
        let profileQuery: PFQuery = PFUser.query()!
        profileQuery.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) { (user, error) -> Void in
            
            if error == nil {
                if let user = user {
                    self.firstName.text = user["firstName"] as? String
                    self.lastName.text = user["lastName"] as? String
                    self.email.text = user["email"] as? String
                    
                    // Stops activity indicator
                    self.activityIndicator.stopAnimating()
                    loadingView.removeFromSuperview()
                    container.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
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
    
    
    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    /** User clicked done, edit profile info */
    @IBAction func done(sender: AnyObject) {
        
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
            loadingView.frame.size.height / 2)
        activityIndicator.hidesWhenStopped = true
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        view.addSubview(container)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        
        // Change user's profile info
        let profileQuery = PFQuery(className: "_User")
        profileQuery.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) {
            (user: PFObject?, error: NSError?) -> Void in
            
            if error != nil {
                // Stops activity indicator
                self.activityIndicator.stopAnimating()
                loadingView.removeFromSuperview()
                container.removeFromSuperview()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                self.displayAlert("Error", message: String(error))
                
            } else if let user = user {
                
                // update user info
                user["firstName"] = self.firstName.text
                user["lastName"] = self.lastName.text
                user["fullName"] = (self.firstName.text! + " " + self.lastName.text!)
                user["email"] = self.email.text
                user["username"] = self.email.text
                
                user.saveInBackgroundWithBlock{( sucess, error) -> Void in
                    if error == nil {
                        
                        // Stops activity indicator
                        self.activityIndicator.stopAnimating()
                        loadingView.removeFromSuperview()
                        container.removeFromSuperview()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        print("Successfully changed user info!")
                        NSNotificationCenter.defaultCenter().postNotificationName("RefreshMasterNotification", object: nil)
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        
                        // Stops activity indicator
                        self.activityIndicator.stopAnimating()
                        loadingView.removeFromSuperview()
                        container.removeFromSuperview()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        self.displayAlert("Error", message: "Could not save the changes! Try again later.")
                    }
                }
            }
        }
    }
    
    
    /** Done button enabled only when user has entered all info */
    func textChanged(sender: NSNotification) {
        if firstName.hasText() && lastName.hasText() && email.hasText() {
            doneButton.enabled = true
        } else {
            doneButton.enabled = false
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

}
