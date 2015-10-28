//
//  WatchListMovieCell.swift
//  
//
//  Created by Mathias Quintero on 10/20/15.
//
//

import UIKit

class WatchListMovieCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            if let unwrappedMovie = movie {
//                backgroundCardView.image = unwrappedMovie.poster
                moviePosterView.image = unwrappedMovie.poster
                titleLabel.text = unwrappedMovie.titel
                descriptionLabel.text = unwrappedMovie.description
            }
        }
    }
    
//    @IBOutlet weak var backgroundCardView: UIImageView! {
//        didSet {
//            backgroundCardView.layer.masksToBounds = true
//            let effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//            let effectView = UIVisualEffectView(effect: effect)
//            effectView.alpha = 0.6
//            effectView.frame = backgroundCardView.bounds
//            backgroundCardView.addSubview(effectView)
//            backgroundColor = UIColor.clearColor()
//            selectionStyle = UITableViewCellSelectionStyle.None
//        }
//    }
    
    @IBOutlet weak var moviePosterView: UIImageView! {
        didSet {
            backgroundColor = UIColor.clearColor()
            selectionStyle = UITableViewCellSelectionStyle.None
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
