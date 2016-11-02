//
//  ActorSearchResultTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 5/14/16.
//  Copyright © 2016 LS1 TUM. All rights reserved.
//

import UIKit
import MCSwipeTableViewCell

class ActorFollowingTableViewCell: MCSwipeTableViewCell {
    
    // MARK: Data
    
    var actor: Actor? {
        didSet {
            if let unwrappedActor = actor {
                nameLabel.text = unwrappedActor.name
                if let imageOfActor = unwrappedActor.headshot {
                    headshotImageView.image = imageOfActor
                } else {
                    headshotImageView.image = UIImage(named: "avatar")
                }
            }
        }
    }
    
    // MARK: UI Elements
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var headshotImageView: UIImageView! {
        didSet {
            backgroundColor = UIColor.clear
            headshotImageView.layer.cornerRadius = CGFloat (20)
            headshotImageView.clipsToBounds = true
            headshotImageView.layer.frame = headshotImageView.layer.frame.insetBy(dx: 20, dy: 20)
            headshotImageView.layer.borderColor = UIColor.white.cgColor
            headshotImageView.layer.borderWidth = 2.0
        }
    }
}
