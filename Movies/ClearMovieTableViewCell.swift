//
//  ClearMovieTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 10/17/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class ClearMovieTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            if let unwrappedMovie = movie {
                titleLabel.text = unwrappedMovie.title
                descriptionLabel.text = unwrappedMovie.description
                if let poster = unwrappedMovie.poster {
                    posterImageView.image = poster
                } else {
                    posterImageView.image = UIImage(named: "placeholder")
                }
            }
        }
    }

    
    @IBOutlet weak var posterImageView: UIImageView! {
        didSet {
            backgroundColor = UIColor.clear
            posterImageView.layer.shadowOpacity = 0.4
            posterImageView.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}
