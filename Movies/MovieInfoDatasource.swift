//
//  MovieInfoDatasource.swift
//  Movies
//
//  Created by Mathias Quintero on 12/31/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation

protocol MovieInfoDataSource {
    
    // Protocol for the Object that will cache the Movies and Actors
    
    func knownMovie(id: String) -> Movie?
    func learnMovie(id:String, movie: Movie)
    func knownPerson(id: String) -> Actor?
    func learnPerson(id: String, actor: Actor)
    func addToWatchList(id: Int)
    func removeFromWatchList(id: Int)
    func isMovieInWatchList(id: Int) -> Bool
    func reArrangeWatchList(from: Int, to: Int)
    func fetchTickets(requestingView: TicketReceiverProtocol)
    
}