//
//  ActorTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 10/16/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import MCSwipeTableViewCell

class ActorTableViewCell: MCSwipeTableViewCell {
    
    // MARK: Data
    
    var color = Constants.tintColor
    
    var actor: (Actor, String)? {
        didSet {
            if let unwrappedActor = actor?.0, role = actor?.1{
                nameLabel.text = unwrappedActor.name
                roleLabel.text = role
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
            backgroundColor = UIColor.clearColor()
            setUpImageView()
        }
    }
    
    func setUpImageView() {
        headshotImageView.layer.cornerRadius = CGFloat (headshotImageView.frame.width / 2)
        headshotImageView.clipsToBounds = true
        headshotImageView.layer.frame = CGRectInset(headshotImageView.layer.frame, 20, 20)
        headshotImageView.layer.borderColor = color.CGColor
        headshotImageView.layer.borderWidth = 2.0
    }
}
