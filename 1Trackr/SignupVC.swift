//
//  SignupVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/11/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit
import Parse

class SignupVC: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Initialize label variables
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var confirmPasswordLabel: UILabel!
    @IBOutlet var pickerLabel: UILabel!
    
    
    // Initialize textfield variables
    @IBOutlet var firstName: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    @IBOutlet var pickerTextField: UITextField!
    
    
    // Activity indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // Picker view variables - Internships
    var pickOption = ["", "Zero Waste Internship", "PAUSD Energy Conservation Data Analysis Internship", "PAUSD School Site Energy Auditing Internship", "Service Learning Program Manager Internship"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creates and customizes UI Picker View
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerTextField.inputView = pickerView
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
        label.text = "Internships"
        label.textAlignment = NSTextAlignment.Center
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexSpace,textBtn,flexSpace,doneButton], animated: true)
        pickerTextField.inputAccessoryView = toolBar
        
        setVisualEffects()
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.firstName.delegate = self
        self.email.delegate = self
        self.password.delegate = self
        self.confirmPassword.delegate = self
    }
    
    
    /** Sign user up */
    @IBAction func signup(sender: AnyObject) {
        
        if firstName.text == "" || password.text == "" || confirmPassword.text == "" || email.text == "" || pickerTextField.text == "" {
            
            displayAlert("Missing Field(s)", message: "Please enter all fields!")
            
        } else if password.text != confirmPassword.text {
            
            displayAlert("Password Error", message: "Your passwords don't match!")
            
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
            
            
            // Sets user data on parse
            let user = PFUser()
            user.username = email.text
            user.password = password.text
            user.email = email.text
            user["fullName"] = firstName.text
            user["internship"] = pickerTextField.text
            user["totalMins"] = 0
            
            // Sets default user profile pic
            let profilePic = UIImage(named: "defaultProfilePic")
            let imageData = UIImagePNGRepresentation(profilePic!)
            let imageFile = PFFile(name: "image.jpg", data: imageData!)
            user["profilePic"] = imageFile
            
            
            user.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
                if let error = error {
                    
                    if let errorString = error.userInfo["error"] as? String {
                        
                        // Stop activity indicator
                        self.activityIndicator.stopAnimating()
                        loadingView.removeFromSuperview()
                        container.removeFromSuperview()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        // Sign up failed. Display error message
                        self.displayAlert("Sign up failed", message: errorString)
                    }
                    
                } else {
                    
                    // Stop activity indicator
                    self.activityIndicator.stopAnimating()
                    loadingView.removeFromSuperview()
                    container.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    // Hooray! Let them use the app now.
                    self.performSegueWithIdentifier("showMainScreenFromSignup", sender: self)
                }
            }
        }
    }
    
    
    
    // MARK: - Picker View Controller Data Source
    
    func donePressed(sender: UIBarButtonItem) {
        
        pickerTextField.resignFirstResponder()
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    // Sets font, text, and position of texts in picker view
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.text = pickOption[row]
        pickerLabel.font = UIFont.systemFontOfSize(15)
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickOption[row]
    }
    
    /** Sets visual effects on text fields and borders */
    func setVisualEffects() {
        
        // Colors
        let borderColor : UIColor = UIColor(red: 59/255.0, green: 181/255.0, blue: 143/255.0, alpha: 1.0)
        let placeholderTextColor : UIColor = UIColor(red: 0/255.0, green: 0/255.0, blue:0/255.0, alpha: 0.2)
        
        // Sets placeholder text color
        firstName.attributedPlaceholder = NSAttributedString(string:"Full Name",
            attributes:[NSForegroundColorAttributeName: placeholderTextColor])
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: placeholderTextColor])
        confirmPassword.attributedPlaceholder = NSAttributedString(string:"Confirm Password",
            attributes:[NSForegroundColorAttributeName: placeholderTextColor])
        email.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSForegroundColorAttributeName: placeholderTextColor])
        pickerTextField.attributedPlaceholder = NSAttributedString(string: "Select Your Internship", attributes: [NSForegroundColorAttributeName: placeholderTextColor, NSFontAttributeName : UIFont.systemFontOfSize(14)])
        
        // Gives labels rounded edges
        firstNameLabel.layer.borderWidth = 1
        firstNameLabel.layer.borderColor = borderColor.CGColor
        firstNameLabel.layer.cornerRadius = 23
        passwordLabel.layer.borderWidth = 1
        passwordLabel.layer.borderColor = borderColor.CGColor
        passwordLabel.layer.cornerRadius = 23
        confirmPasswordLabel.layer.borderWidth = 1
        confirmPasswordLabel.layer.borderColor = borderColor.CGColor
        confirmPasswordLabel.layer.cornerRadius = 23
        emailLabel.layer.borderWidth = 1
        emailLabel.layer.borderColor = borderColor.CGColor
        emailLabel.layer.cornerRadius = 23
        pickerLabel.layer.borderWidth = 1
        pickerLabel.layer.borderColor = borderColor.CGColor
        pickerLabel.layer.cornerRadius = 23
        
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
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
