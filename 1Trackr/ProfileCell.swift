//
//  ProfileCell.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 12/26/15.
//  Copyright © 2015 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var choosePictureButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePic.layer.cornerRadius = profilePic.frame.size.width/2
        profilePic.clipsToBounds = true
        choosePictureButton.layer.cornerRadius = choosePictureButton.frame.size.width / 2
        choosePictureButton.clipsToBounds = true
        
        profilePic.layer.borderWidth = 3
        profilePic.layer.borderColor = UIColor.whiteColor().CGColor
    }
}
