//
//  WatchListMovieCell.swift
//  
//
//  Created by Mathias Quintero on 10/20/15.
//
//

import UIKit
import MCSwipeTableViewCell

class WatchListMovieCell: MCSwipeTableViewCell {
    
    var movie: Movie? {
        didSet {
            if let unwrappedMovie = movie {
                moviePosterView.image = unwrappedMovie.poster
                titleLabel.text = unwrappedMovie.title
                descriptionLabel.text = unwrappedMovie.description
            }
        }
    }
    
    @IBOutlet weak var moviePosterView: UIImageView! {
        didSet {
            backgroundColor = Constants.tintColor
            selectionStyle = UITableViewCellSelectionStyle.None
            self.defaultColor = Constants.tintColor
            self.selectedBackgroundView?.backgroundColor = Constants.tintColor
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cardBackgroundView: UIView! {
        didSet {
            cardBackgroundView.layer.shadowOpacity = 0.4
            cardBackgroundView.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        }
    }
    
}
