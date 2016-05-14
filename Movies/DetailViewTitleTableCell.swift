//
//  DetailViewTitleTableCell.swift
//  Movies
//
//  Created by Mathias Quintero on 10/15/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class DetailViewTitleTableCell: UITableViewCell {

    
    // MARK: DATA
    
    var movie: Movie? {
        didSet {
            if let poster = movie?.poster {
                posterImageView.image = poster
            }
            titleLabel.text = movie?.title
            yearLabel.text = movie?.year.description
            if let ratingString =  movie?.rating.description {
                rating.text = "★" + ratingString
            } else {
                rating.text = "No Rating Available"
            }
            
        }
    }
    
    // MARK: UI Elements
    
    @IBOutlet weak var posterImageView: UIImageView! {
        didSet {
            posterImageView.layer.shadowOpacity = 0.4
            posterImageView.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var rating: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel! {
        didSet {
            backgroundColor = UIColor.clearColor()
        }
    }
    
}
