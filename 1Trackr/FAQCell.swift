//
//  FAQCell.swift
//  1Trackr
//
//  Created by Haoming(Jerry) Huang on 1/5/16.
//  Copyright © 2016 Haoming(Jerry) Huang. All rights reserved.
//

import UIKit

class FAQCell: UITableViewCell {
    
    
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
