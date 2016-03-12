//
//  FAQTableVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 1/5/16.
//  Copyright © 2016 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit
import Parse

class FAQTableVC: UITableViewController {
    
    
    // Initialize variables
    var questions = [String]()
    var answers = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
    
    
    /** Refresh FAQ's */
    func refresh() {
        
        // Accesses FAQ class on Parse.com
        let faqQuery = PFQuery(className: "FAQ")
        faqQuery.whereKey("tag", equalTo: "faq")
        
        faqQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if let objects = objects {
                
                self.questions.removeAll()
                self.answers.removeAll()
                
                for object in objects {
                    self.questions.append(object["question"] as! String)
                    self.answers.append(object["answer"] as! String)
                }
                
                self.tableView.reloadData()
            } else {
                self.displayAlert("Error", message: "Could not load FAQ's!")
            }
        }
    }
    
    
    /** Displays pop up alert */
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
        return questions.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! FAQCell

        // Configure the cell...
        cell.questionLabel.text = questions[indexPath.row]
        cell.answerLabel.text = answers[indexPath.row]

        return cell
    }

}
