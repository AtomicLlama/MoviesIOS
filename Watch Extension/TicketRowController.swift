//
//  TicketRowController.swift
//  Movies
//
//  Created by Mathias Quintero on 11/16/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import WatchKit

class TicketRowController: NSObject {
    
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var theatreLabel: WKInterfaceLabel!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var imageView: WKInterfaceImage!
    
    var ticket: TicketEntity? {
        didSet {
            if let unwrappedTicket = ticket {
                theatreLabel.setText(unwrappedTicket.theatre.name)
                timeLabel.setText("22:00")
                titleLabel.setText(unwrappedTicket.movie.title)
                imageView.setImage(unwrappedTicket.movie.poster)
            }
        }
    }
    
}
