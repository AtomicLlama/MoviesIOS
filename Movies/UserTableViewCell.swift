//
//  UserTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView! {
        didSet {
            avatarView.layer.cornerRadius = CGFloat (avatarView.frame.width / 2)
            avatarView.clipsToBounds = true
            avatarView.layer.frame = avatarView.layer.frame.insetBy(dx: 20, dy: 20)
            avatarView.layer.borderColor = Constants.tintColor.cgColor
            avatarView.layer.borderWidth = 2.0
        }
    }
    
    
    var user: User? {
        didSet {
            if let personUnwrapped = user {
                personNameLabel.text = personUnwrapped.name
                if let imageOfHeadshot = personUnwrapped.image {
                    avatarView.image = imageOfHeadshot
                } else {
                    avatarView.image = UIImage(named: "avatar")
                }
            }
        }
    }

}
