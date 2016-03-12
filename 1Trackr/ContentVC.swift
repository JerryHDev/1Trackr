//
//  ContentVC.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/12/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit

class ContentVC: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    
    var pageIndex: Int!
    var titleText: String!
    var descriptionText: String!
    var imageFile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.imageView.image = UIImage(named: self.imageFile)
        self.titleLabel.text = self.titleText
        self.descriptionLabel.text = self.descriptionText
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
