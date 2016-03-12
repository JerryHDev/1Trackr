//
//  SettingsTableVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/27/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class SettingsTableVC: UITableViewController, MFMailComposeViewControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
    }
    
    
    // MARK: Send mail feeback from app
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["jerryh.develop@gmail.com"])
        mailComposerVC.setSubject("1Trackr Feedback/Support")
        mailComposerVC.setMessageBody("1Trackr feedback/support requested. Type feedback or support below:", isHTML: false)
        
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    /** Log User Out Segue */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "logOut" {
            
            PFUser.logOut()
            _ = PFUser.currentUser()
            print("USER LOGGED OUT")
        }
    }
    
    
    
    /** Gets which section and row was selected */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Feedback tapped
        if indexPath.section == 2 && indexPath.row == 0 {
           
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
        
        // Rate app tapped
        if indexPath.section == 1 && indexPath.row == 0 {
            UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1072273630")!);
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
