//
//  LoginVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/11/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit
import Parse

class LoginVC: UIViewController, UITextFieldDelegate {
    
    // Initialize label variables
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    
    // Initialize textfield variables
    @IBOutlet var password: UITextField!
    @IBOutlet var email: UITextField!
    
    
    // Activity indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setVisualEffects()
        
        
        // Adds tap recognition
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.email.delegate = self
        self.password.delegate = self
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Password Reset", message: "Please enter your email address", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Email"
           
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            PFUser.requestPasswordResetForEmailInBackground(textField.text!, block: { (success, error) -> Void in
                if !success {
                    self.displayAlert("Password Reset Error", message: "The email address is incorrect or not registered")
                }
                else {
                    self.displayAlert("Password Resseted", message: "Check your email for instructions on setting a new password!")
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
   
    
    /** Logs the user in */
    @IBAction func login(sender: AnyObject) {
        
        if email.text == "" || password.text == "" {
            
            displayAlert("Missing Field(s)", message: "Please enter email or password!")
            
        } else {
            
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
            
            PFUser.logInWithUsernameInBackground(email.text!, password: password.text!) { (user: PFUser?, error: NSError?) -> Void in
                
                if user != nil {
                    
                    // Stops activity indicator
                    self.activityIndicator.stopAnimating()
                    loadingView.removeFromSuperview()
                    container.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    // Do stuff after successful login.
                    self.performSegueWithIdentifier("showMainScreenFromLogin", sender: self)
                    
                } else {
                    
                    // The login failed. Check error to see why.
                    if let errorString = error?.userInfo["error"] as? String {
                        
                        // Stops activity indicator
                        self.activityIndicator.stopAnimating()
                        loadingView.removeFromSuperview()
                        container.removeFromSuperview()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        // Log in failed. Display the error message.
                        self.displayAlert("Log in failed", message: errorString)
                    }
                }
            }
        }
    }
    
    
    func setVisualEffects() {
        
        // Colors
        let borderColor : UIColor = UIColor(red: 59/255.0, green: 181/255.0, blue: 143/255.0, alpha: 1.0)
        let placeholderTextColor : UIColor = UIColor(red: 0/255.0, green: 0/255.0, blue:0/255.0, alpha: 0.2)
        
        // Sets placeholder text color
        email.attributedPlaceholder = NSAttributedString(string:"Email",
            attributes:[NSForegroundColorAttributeName: placeholderTextColor])
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: placeholderTextColor])
        
        // Gives labels rounded edges
        emailLabel.layer.borderWidth = 1
        emailLabel.layer.borderColor = borderColor.CGColor
        emailLabel.layer.cornerRadius = 23
        passwordLabel.layer.borderWidth = 1
        passwordLabel.layer.borderColor = borderColor.CGColor
        passwordLabel.layer.cornerRadius = 23
    }
    
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    /** Keyboard dismisses when screen tapped */
    func DismissKeyboard() {
        view.endEditing(true)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}