//
//  TrailerViewCell.swift
//  
//
//  Created by Mathias Quintero on 11/1/15.
//
//

import UIKit
import YouTubePlayer


class TrailerViewCell: UITableViewCell {
    
    var id: String? {
        didSet {
            if let unwrappedID = id {
                player.loadVideoID(unwrappedID)
            }
        }
    }
    
    @IBOutlet weak var player: YouTubePlayerView! {
        didSet {
            backgroundColor = UIColor.clearColor()
        }
    }
}
