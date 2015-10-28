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
            titleLabel.text = movie?.titel
            yearLabel.text = movie?.year.description
            if let ratingString =  movie?.rating.description {
                rating.text = "★" + ratingString
            } else {
                rating.text = "No Rating Available"
            }
            
        }
    }
    
    // MARK: UI Elements
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var rating: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel! {
        didSet {
            backgroundColor = UIColor.clearColor()
        }
    }
    
}
