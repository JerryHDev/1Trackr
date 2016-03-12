//
//  HomeTableVC.swift
//  1Trackr
//
//  Created by Jerry Huang on 1/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class HomeTableVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return 2
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("video", forIndexPath: indexPath) as! HomeCell
        
        // Configure the cell...
        if indexPath.row == 0 {
            
            let youtubeURL = "https://www.youtube.com/embed/_wD9PgswUVA"
            
            cell.videoView.loadHTMLString("<iframe width=\"100%\" height=\"\(cell.videoView.frame.height)\" src=\"\(youtubeURL)?&playsinline=1\" frameborder=\"0\" allowfullscreen<>/iframe>", baseURL: nil)
            cell.videoView.allowsInlineMediaPlayback = true
            cell.videoView.scrollView.scrollEnabled = false;
            cell.videoView.scrollView.bounces = false;
            cell.postTitleLabel.text = "Get Involved Internship Rollout"
        }
            
        else if indexPath.row == 1 {
            
            let youtubeURL = "https://www.youtube.com/embed/-2eQ5iKm8dU"
            
            cell.videoView.loadHTMLString("<iframe width=\"100%\" height=\"\(cell.videoView.frame.height)\" src=\"\(youtubeURL)?&playsinline=1\" frameborder=\"0\" allowfullscreen<>/iframe>", baseURL: nil)
            cell.videoView.allowsInlineMediaPlayback = true
            cell.videoView.scrollView.scrollEnabled = false;
            cell.videoView.scrollView.bounces = false;
            cell.postTitleLabel.text = "Paly Service Day 2015"
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
