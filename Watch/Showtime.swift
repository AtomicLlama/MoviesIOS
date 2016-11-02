//
//  MovieTime.swift
//  Movies
//
//  Created by Mathias Quintero on 12/27/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation

class Showtime {
    
    let time: Date
    let name: String
    let theatre: Theatre
    
    init(name: String, time: Date, theatre: Theatre) {
        self.name = name
        self.time = time
        self.theatre = theatre
    }
    
}
