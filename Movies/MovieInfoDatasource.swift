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
    
    func knownMovie(_ id: String) -> Movie?
    func learnMovie(_ id:String, movie: Movie)
    func knownPerson(_ id: String) -> Actor?
    func learnPerson(_ id: String, actor: Actor)
    func addToWatchList(_ id: Int)
    func removeFromWatchList(_ id: Int)
    func addToSubscriptions(_ id: Int)
    func removeFromSubscriptions(_ id: Int)
    func isMovieInWatchList(_ id: Int) -> Bool
    func isActorInSubscriptions(_ id: Int) -> Bool
    func reArrangeWatchList(_ from: Int, to: Int)
    func fetchTickets(_ requestingView: TicketReceiverProtocol)
    
}
