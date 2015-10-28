//
//  HeadShotTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 10/17/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class HeadShotTableViewCell: UITableViewCell {
    
    var person: Actor? {
        didSet {
            if let personUnwrapped = person {
                nameLabel.text = personUnwrapped.name
                if let imageOfHeadshot = personUnwrapped.headshot {
                    headShotView.image = imageOfHeadshot
                } else {
                    headShotView.image = UIImage(named: "avatar")
                }
            }
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headShotView: UIImageView! {
        didSet {
            backgroundColor = UIColor.clearColor()
            headShotView.layer.cornerRadius = CGFloat (headShotView.frame.width / 2)
            headShotView.clipsToBounds = true
        }
    }
    
}
