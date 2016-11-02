//
//  TicketTableViewCell.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class TicketTableViewCell: UITableViewCell {

    var ticket: TicketEntity? {
        didSet {
            if let ticketObject = ticket {
                movieImageView.image = ticketObject.movie.detailImage ?? UIImage(named: "film")
                theatreLabel.text = ticketObject.theatre.name
                titleLabel.text = ticketObject.movie.title
                //timeLabel.text = ticketObject.time.description
                if let singleTicket = ticketObject as? Ticket {
                    ticketTypeImageView.image = UIImage(named: "single")
                    ticketTypeLabel.text = "Single"
                    SeatLabel.text = singleTicket.seat
                } else if let groupTicket = ticketObject as? GroupTicket {
                    ticketTypeImageView.image = UIImage(named: "group")
                    ticketTypeLabel.text = "Group"
                    let sortedTickets = groupTicket.tickets.sorted() { return $0.0.seat < $0.1.seat }
                    if let firstSeat = sortedTickets.first?.seat, let lastSeat = sortedTickets.last?.seat {
                        SeatLabel.text = firstSeat + " - " + lastSeat
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var movieImageView: UIImageView! {
        didSet {
            movieImageView.clipsToBounds = true
            backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var ticketTypeImageView: UIImageView!
    @IBOutlet weak var ticketTypeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var SeatLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var theatreLabel: UILabel!
    @IBOutlet weak var cardBackgroundView: UIView! {
        didSet {
            cardBackgroundView.layer.shadowOpacity = 0.4
            cardBackgroundView.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
            selectionStyle = UITableViewCellSelectionStyle.none
        }
    }
    
}
