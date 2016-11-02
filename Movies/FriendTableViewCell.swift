//
//  FriendTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 1/23/16.
//  Copyright © 2016 LS1 TUM. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    var person: Person? {
        didSet {
            if let item = person {
                avatarView.image = item.image
                nameLabel.text = item.name
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var avatarView: UIImageView! {
        didSet {
            avatarView.layer.cornerRadius = CGFloat (avatarView.frame.width / 2)
            avatarView.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!

}
