//
//  MainTabBC.swift
//  Track It!
//
//  Created by Haoming(Jerry) Huang on 12/11/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit
import Parse

class MainTBC: UITabBarController, UITabBarControllerDelegate {
    
    var button: UIButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // Get tab bar and set base styles
        let tabBar = self.tabBar;
        tabBar.backgroundColor = UIColor.whiteColor()
        
        // Without this, images can extend off top of tab bar
        tabBar.clipsToBounds = true
        
        // For each tab item..
        for var i = 0; i < tabBar.items?.count; i++ {
            let tabBarItem = (tabBar.items?[i])! as UITabBarItem
            
            // Adjust tab images (Like mstysf says, these values will vary)
            tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
            
            var imageName = ""
            switch (i) {
            case 0: imageName = "home"
            case 1: imageName = "hours"
            case 2: imageName = "addButton"
            case 3: imageName = "profile"
            case 4: imageName = "settings"
            default: break
            }
            tabBarItem.image = UIImage(named:imageName)!.imageWithRenderingMode(.AlwaysOriginal)
            tabBarItem.selectedImage = UIImage(named:imageName + "_selected")!.imageWithRenderingMode(.AlwaysOriginal)
        }
        
        
        // Add background color to middle tabBarItem
        let itemIndex = 2
        let bgColor = UIColor(red: 59/255.0, green: 181/255.0, blue: 143/255.0, alpha: 1.0)
        
        let itemWidth = tabBar.frame.width / CGFloat(tabBar.items!.count)
        let bgView = UIView(frame: CGRectMake(CGFloat (itemWidth * CGFloat(itemIndex)), 0, itemWidth, tabBar.frame.height))
        bgView.backgroundColor = bgColor
        tabBar.insertSubview(bgView, atIndex: 0)
        
        
        // Adds center button
        let middleImage:UIImage = UIImage(named:"addButton")!
        let highlightedMiddleImage:UIImage = UIImage(named:"addButton_selected")!
        addCenterButtonWithImage(middleImage, highlightImage: highlightedMiddleImage)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.username == nil {
            // User not logged in. Go to Welcome screen
            self.performSegueWithIdentifier("showWelcomeScreen", sender: self)
        }
        else {
            // User already logged in. Do nothing
        }
    }
    
    
    //MARK: MIDDLE TAB BAR HANDLER
    func addCenterButtonWithImage(buttonImage: UIImage, highlightImage:UIImage?)
    {
        
        let barWidth = self.tabBar.frame.size.width / 5
        let barHeight = self.tabBar.frame.size.height
        let frame = CGRectMake(0.0, 0.0, buttonImage.size.width + 18, buttonImage.size.height + 18)
        button = UIButton(frame: frame)
        button.setBackgroundImage(buttonImage, forState: UIControlState.Normal)
        button.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
        
        
        let heightDifference:CGFloat = buttonImage.size.height - self.tabBar.frame.size.height
        if heightDifference < 0 {
            button.center = self.tabBar.center;
        }
        else
        {
            var center:CGPoint = self.tabBar.center;
            center.y = center.y - heightDifference/2.0;
            button.center = center;
        }
        
        button.addTarget(self, action: "centerButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    
    // If user chooses center tab, present Add Hour VC
    func centerButtonTapped(sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("addHoursVC") as! AddHoursVC
        let navController = UINavigationController(rootViewController: nextViewController)
        self.presentViewController(navController, animated:true, completion:nil)
    }
    
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        // If user chooses center tab, present Add Hour VC
        if tabBarController.selectedIndex == 2 {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("addHoursVC") as! AddHoursVC
            let navController = UINavigationController(rootViewController: nextViewController)
            self.presentViewController(navController, animated:true, completion:nil)
        }
    }
    
}