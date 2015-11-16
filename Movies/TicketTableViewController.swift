//
//  TicketTableViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class TicketTableViewController: UITableViewController, TicketReceiverProtocol, MovieReceiverProtocol {
    
    func moviesArrived(newMovies: [Movie]) {}
    
    func imageDownloaded() {
        tableView.reloadData()
    }
    
    var fetcher: MovieDataFetcher?
    
    var tickets = [TicketEntity]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let mvc = tabBarController as? MoviesTabBarController {
            fetcher = mvc.dataFetcher
        }
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        fetcher?.fetchTickets(self)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.backgroundColor = UIColor(red:0.82, green:0.44, blue:0.39, alpha:1)
        tableView.separatorColor = UIColor.clearColor()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ticket", forIndexPath: indexPath) as? TicketTableViewCell ?? TicketTableViewCell()
        cell.ticket = tickets[indexPath.row]
        print("New Ticket")
        print(indexPath.row)
        print(indexPath.section)
        cell.ticket?.movie.fetchDetailImage(self)
        return cell
    }
    
    func receiveTickets(tickets: [TicketEntity]) {
        self.tickets = tickets
        tableView.reloadData()
    }

}
