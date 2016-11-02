//
//  MovieTimeTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 12/28/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class MovieTimeTableViewCell: UITableViewCell {
    
    var item: Showtime? {
        didSet{
            if let time = item {
                let dateforamtter = DateFormatter()
                dateforamtter.dateFormat = "HH:mm"
                timeLabel.text = dateforamtter.string(from: time.time as Date)
                titleLabel.text = time.name
            }
        }
    }
    
    @IBOutlet weak var posterImage: UIImageView! {
        didSet {
            self.backgroundColor = UIColor.clear
            posterImage.clipsToBounds = true
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}
