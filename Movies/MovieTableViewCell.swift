//
//  MovieTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 10/15/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    var movie: Movie? {
        didSet {
            if let movieUnwrapped = movie {
                titelLabel.text = movieUnwrapped.titel
                descriptionLabel.text = movieUnwrapped.description
                if let posterImage = movieUnwrapped.poster {
                    posterImageView.image = posterImage
                } else {
                    
                }
            }
        }
    }
    
    @IBOutlet weak var posterImageView: UIImageView! {
        didSet{
            let effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.alpha = 0.7
            effectView.frame = posterImageView.bounds
            posterImageView.addSubview(effectView)
        }
    }
    
    @IBOutlet weak var titelLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}
