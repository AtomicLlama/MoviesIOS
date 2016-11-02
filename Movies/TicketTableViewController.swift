//
//  TicketTableViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class TicketTableViewController: UITableViewController, TicketReceiverProtocol, MovieReceiverProtocol {
    
    func moviesArrived(_ newMovies: [Movie]) {}
    
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
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = Constants.tintColor
        tableView.separatorColor = UIColor.clear
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticket", for: indexPath) as? TicketTableViewCell ?? TicketTableViewCell()
        cell.ticket = tickets[indexPath.row]
        print("New Ticket")
        print(indexPath.row)
        print(indexPath.section)
        cell.ticket?.movie.fetchDetailImage(self)
        return cell
    }
    
    func receiveTickets(_ tickets: [TicketEntity]) {
        self.tickets = tickets
        tableView.reloadData()
    }

}
