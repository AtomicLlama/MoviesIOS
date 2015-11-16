//
//  TicketDetailInterfaceController.swift
//  Movies
//
//  Created by Mathias Quintero on 11/16/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import WatchKit
import Foundation


class TicketDetailInterfaceController: WKInterfaceController {
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var seatLabel: WKInterfaceLabel!
    @IBOutlet var ratingLabel: WKInterfaceLabel!
    @IBOutlet var yearLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var theatreLabel: WKInterfaceLabel!
    @IBOutlet var imageView: WKInterfaceImage!
    @IBOutlet var map: WKInterfaceMap!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let ticket = context as? TicketEntity {
            titleLabel.setText(ticket.movie.title)
            ratingLabel.setText("★" + ticket.movie.rating.description)
            timeLabel.setText("22:00")
            theatreLabel.setText(ticket.theatre.name)
            map.setRegion(MKCoordinateRegion(center: ticket.theatre.location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
            imageView.setImage(ticket.movie.poster)
            yearLabel.setText(ticket.movie.year.description)
            if let single = ticket as? Ticket {
                seatLabel.setText("Seat: " + single.seat!)
            } else if let group = ticket as? GroupTicket {
                seatLabel.setText("Seat: " + group.tickets[0].seat!)
            }
            
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
