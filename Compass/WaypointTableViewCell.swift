//
//  WaypointTableViewCell.swift
//  Compass
//
//  Created by Matthew Marsland on 8/12/19.
//  Copyright © 2019 Tectane. All rights reserved.
//

import UIKit

class WaypointTableViewCell: UITableViewCell {

    //Properties


    @IBOutlet weak var nameLabel: UILabel!
    //@IBOutlet weak var latLabel: UILabel!
    //@IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var disLabel: UILabel!
    @IBOutlet weak var enabledButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //contentView.backgroundColor = UIColor.blue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
