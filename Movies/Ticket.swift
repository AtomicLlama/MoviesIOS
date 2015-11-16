//
//  Ticket.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation

class Ticket: TicketEntity {
    
    let seat: String?
    
    override init(movie: Movie) {
        self.seat = "5H"
        super.init(movie: movie)
    }
    
}