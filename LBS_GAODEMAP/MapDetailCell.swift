//
//  MapDetailCell.swift
//  LBS_GAODEMAP
//
//  Created by denglong on 5/19/16.
//  Copyright © 2016 邓龙. All rights reserved.
//

import UIKit

class MapDetailCell: UITableViewCell {

    @IBOutlet weak var addressName: UILabel!
    @IBOutlet weak var addressDetail: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
