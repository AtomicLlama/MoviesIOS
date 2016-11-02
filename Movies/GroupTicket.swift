//
//  GroupTicket.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation

class GroupTicket: TicketEntity {
    
    var tickets = [Ticket]()
    
    func addTicket(_ ticket: Ticket) {
        tickets.append(ticket)
    }
    
    init(tickets: [Ticket]) {
        self.tickets = tickets
        let movie = tickets[0].movie
        super.init(movie: movie)
    }
    
}
