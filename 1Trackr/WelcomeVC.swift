//
//  WelcomeVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/11/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit


/** Creates a horizontal page view for welcome screen */
class WelcomeVC: UIViewController, UIPageViewControllerDataSource {
    
    
    // Initialize variables
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var pageDescriptions: NSArray!
    var pageImages: NSArray!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        self.pageTitles = NSArray(objects: "Welcome to 1Trackr!", "Hour Tracking", "View Logs", "Saved in the Cloud")
        self.pageDescriptions = NSArray(objects: "Simplify your community service hour tracking process", "Log your service hours as you complete tasks", "View all your logs and edit any mistakes if necessary", "All your service hours are securely saved in the Cloud for easy accessibility")
        //self.pageImages = NSArray(objects: "page1", "hoursDeselected", "")
        
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        
        
        let startVC = self.viewControllerAtIndex(0) as ContentVC
        
        let viewControllers = NSArray(object: startVC)
        
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - 100)
        
        self.addChildViewController(self.pageViewController)
        
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    
    /** Method function: Create a new content view controller and assign correct title and image */
    func viewControllerAtIndex(index: Int) -> ContentVC {
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            
            return ContentVC()
        }
        
        let vc: ContentVC = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentVC
        
        //vc.imageFile = self.pageImages[index] as! String
        
        vc.titleText = self.pageTitles[index]as! String
        
        vc.descriptionText = self.pageDescriptions[index]as! String
        
        vc.pageIndex = index
        
        return vc
    }
    
    
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentVC
        
        var index = vc.pageIndex as Int
        
        
        if (index == 0 || index == NSNotFound) {
            
            return nil
        }
        
        index--
        
        return self.viewControllerAtIndex(index)
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentVC
        
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound) {
            
            return nil
        }
        
        index++
        
        if (index == self.pageTitles.count) {
            
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        
        return 0
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
