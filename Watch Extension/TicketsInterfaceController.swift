//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Mathias Quintero on 11/16/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire


class TicketsInterfaceController: WKInterfaceController, TicketReceiverProtocol, MovieReceiverProtocol {
    
    let fetcher = MovieDataFetcher()
    
    func receiveTickets(_ tickets: [TicketEntity]) {
        self.tickets = tickets
        for ticket in tickets {
            ticket.movie.subscribeToImage(self)
        }
        reloadTable()
    }
    
    func imageDownloaded() {
        reloadTable()
    }
    
    var currentTicket: TicketEntity?
    
    
    @IBOutlet var table: WKInterfaceTable!
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        pushController(withName: "ticket", context: tickets[rowIndex])
    }
    
    func reloadTable() {
        table.setNumberOfRows(tickets.count, withRowType: "ticket")
        if tickets.count > 0 {
            for i in 0...tickets.count-1 {
                let row = table.rowController(at: i) as? TicketRowController
                row?.ticket = tickets[i]
            }
        }
    }
    
    func moviesArrived(_ newMovies: [Movie]) {
        fetcher.fetchTickets(self)
        reloadTable()
    }
    
    var tickets = [TicketEntity]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func didAppear() {
        fetcher.fetchTickets(self)
        reloadTable()
    }

    override func willActivate() {
        super.willActivate()
        fetcher.receiver = self
        fetcher.fetchNewMovies()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
