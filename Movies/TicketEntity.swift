
//
//  TicketEntity.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation

class TicketEntity {
    
    let movie: Movie
    let theatre: Theatre
    let time: NSDate
    
    init(movie: Movie) {
        self.movie = movie
        theatre = Theatre()
        time = NSDate()
    }
    
}