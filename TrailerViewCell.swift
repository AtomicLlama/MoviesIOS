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

    var videoPlayerView = YouTubePlayerView()
    
    var id: String? {
        didSet {
            if let unwrappedID = id {
                videoPlayerView.loadVideoID(unwrappedID)
            }
        }
    }
    
    @IBOutlet weak var label: UILabel! {
        didSet {
            backgroundColor = UIColor.clearColor()
            addSubview(videoPlayerView)
        }
    }
    
    func playVideo() {
        videoPlayerView.play()
    }
}
