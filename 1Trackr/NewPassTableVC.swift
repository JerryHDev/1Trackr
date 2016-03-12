//
//  NewPassTableVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/27/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit
import Parse

class NewPassTableVC: UITableViewController, UITextFieldDelegate {
    
    
    // Initialize textfield variables
    @IBOutlet var currentPass: UITextField!
    @IBOutlet var newPass: UITextField!
    @IBOutlet var confirmPass: UITextField!
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    // Activity indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        // Detects when text in textfield is changed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        saveButton.enabled = false

        
        // Adds tap recognition
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        self.currentPass.delegate = self
        self.newPass.delegate = self
        self.confirmPass.delegate = self
        
    }

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    /** User clicked save, save new password */
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
            loadingView.frame.size.height / 2)
        activityIndicator.hidesWhenStopped = true
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        view.addSubview(container)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        
        PFUser.logInWithUsernameInBackground(PFUser.currentUser()!.username!, password: currentPass.text!) { (user, error) -> Void in
            
            if user != nil {
                
                let passwordCheckQuery: PFQuery = PFUser.query()!
                passwordCheckQuery.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!, block: { (user, error) -> Void in
                    
                    if error == nil {
                        
                        if self.newPass.text == self.confirmPass.text {
                            let currentUser: PFObject = user! as PFObject
                            PFUser.currentUser()
                            currentUser["password"] = self.newPass.text
                            
                            currentUser.saveInBackgroundWithBlock({ (success, ErrorType) -> Void in
                                if error == nil {
                                    // Stops activity indicator
                                    self.activityIndicator.stopAnimating()
                                    loadingView.removeFromSuperview()
                                    container.removeFromSuperview()
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                    print("Password changed!!!")
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                } else {
                                    // Stops activity indicator
                                    self.activityIndicator.stopAnimating()
                                    loadingView.removeFromSuperview()
                                    container.removeFromSuperview()
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                    
                                    self.displayAlert("Error", message: "Could not save the new password! Try again later.")
                                }
                            })
                            
                        } else {
                            // Stops activity indicator
                            self.activityIndicator.stopAnimating()
                            loadingView.removeFromSuperview()
                            container.removeFromSuperview()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            self.displayAlert("Error", message: "Passwords don't match!")
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
                })
                
            } else {
                
                // Password change failed. Check error to see why.
                if let errorString = error?.userInfo["error"] as? String {
                    
                    // Stops activity indicator
                    self.activityIndicator.stopAnimating()
                    loadingView.removeFromSuperview()
                    container.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    // Failed to change password. Display the error message.
                    self.displayAlert("Password change failed", message: errorString)
                }
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /** Save button enabled only when user has entered all info */
    func textChanged(send: NSNotification) {
        if currentPass.hasText() && newPass.hasText() && confirmPass.hasText() {
            saveButton.enabled = true
        } else {
            saveButton.enabled = false
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
