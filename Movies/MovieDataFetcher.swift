//
//  MovieDataFetcher.swift
//  Movies
//
//  Created by Mathias Quintero on 10/18/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

protocol ActorReceiverProtocol {
    func receiveActors(actors: [Actor])
}

class MovieDataFetcher: MovieInfoDataSource {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var getter: WatchListGetter?
    
    var tickets = [TicketEntity]()
    
    var receiver: MovieReceiverProtocol?
    
    var watchlistSubscriber: MovieReceiverProtocol?
    
    var subscriptionsSubscriber: ActorReceiverProtocol?
    
    let newMoviesURLString = "https://moviesbackend.herokuapp.com/featured"
    
    var knownActors = [String:Actor]()
    
    var knownMovies = [String:Movie]()
    
    var watchList = [Int]()
    
    var subs = [Int]()
    
    func getDefaultsFromMemory() {
        self.getter?.getWatchList() { (array) in
            self.watchList = array
            if let view = self.watchlistSubscriber {
                self.getListOfMovies(view)
            }
        }
        self.getter?.getSubscriptions() { (array) in
            self.subs = array
            if let view = self.subscriptionsSubscriber {
                self.getActorsFromSubscriptions(view)
            }
        }
    }
    
    func fetchNewMovies() {
        Alamofire.request(.GET, newMoviesURLString).responseArray() { (response: Response<[Movie], NSError>) in
            if var movies = response.result.value {
                for i in 0..<movies.count {
                    if let movie = self.knownMovies[movies[i].id.description] {
                        movies[i] = movie
                    } else {
                        self.knownMovies[movies[i].id.description] = movies[i]
                    }
                    movies[i].delegate = self
                    if let receiver = self.receiver {
                        movies[i].subscribeToImage(receiver)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.receiver?.moviesArrived(movies)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.receiver?.moviesArrived([])
                }
            }
        }
        
    }
    
    func fetchTickets(requestingView: TicketReceiverProtocol) {
        requestingView.receiveTickets(tickets)
    }
    
    func addToSubscriptions(id: Int) {
        subs.append(id)
        getter?.addSubscription(id)
    }
    
    func removeFromSubscriptions(id: Int) {
        getter?.removeSubscription(id)
        subs = subs.filter() { item in
            return item != id
        }
    }
    
    func addToWatchList(id: Int) {
        watchList.append(id)
        getter?.addToWatchList(id)
    }
    
    func removeFromWatchList(id: Int) {
        getter?.removeFromWatchList(id)
        watchList = watchList.filter() { item in
            return item != id
        }
    }
    
    func isMovieInWatchList(id: Int) -> Bool {
        return watchList.contains(id)
    }
    
    func isActorInSubscriptions(id: Int) -> Bool {
        return subs.contains(id)
    }
    
    func getListOfMovies(delegate: MovieReceiverProtocol) {
        getMoviesForWatchList(watchList, delegate: delegate)
    }
    
    func getActorsFromSubscriptions(delegate: ActorReceiverProtocol) {
        getListOfActors(subs, delegate: delegate)
    }
    
    func getListOfActors(ids: [Int], delegate: ActorReceiverProtocol) {
        if ids.isEmpty {
            delegate.receiveActors([])
            return
        }
        subscriptionsSubscriber = delegate
        var actors = [Actor]()
        for iterator in 0..<ids.count {
            if let alreadyKnownActor = self.knownActors[ids[iterator].description] {
                actors.append(alreadyKnownActor)
                if iterator == ids.count - 1 {
                    actors.sortInPlace() { (a,b) in
                        return a.name <= b.name
                    }
                    delegate.receiveActors(actors)
                }
            } else {
                Alamofire.request(.GET, getActorURL(ids[iterator])).responseObject() { (response: Response<Actor,NSError>) in
                    if let actor = response.result.value {
                        actors.append(actor)
                        actors.sortInPlace() { (a,b) in
                            return a.name <= b.name
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            delegate.receiveActors(actors)
                        }
                    }
                }
            }
        }
    }
    
    func getMovieURL(id: Int) -> String {
        return "http://api.themoviedb.org/3/movie/" + id.description + "?api_key=18ec732ece653360e23d5835670c47a0"
    }
    
    func getActorURL(id: Int) -> String {
        return "http://api.themoviedb.org/3/person/" + id.description + "?api_key=18ec732ece653360e23d5835670c47a0"
    }
    
    func getMoviesForWatchList(ids: [Int], delegate: MovieReceiverProtocol) {
        if ids.count == 0 {
            delegate.moviesArrived([])
            return
        }
        watchlistSubscriber = delegate
        var movies = [Movie]()
        for iterator in 0..<ids.count {
            if let alreadyKnownMovie = self.knownMovies[ids[iterator].description] {
                movies.append(alreadyKnownMovie)
                movies.sortInPlace() { (a,b) in
                    return a.title  <= b.title
                }
                if iterator == ids.count - 1 {
                    delegate.moviesArrived(movies)
                }
            } else {
                Alamofire.request(.GET, getMovieURL(ids[iterator])).responseObject() { (response: Response<Movie, NSError>) in
                    if let movie = response.result.value {
                        self.learnMovie(movie.id.description, movie: movie)
                        movies.append(movie)
                    }
                    movies.sortInPlace() { (a,b) in
                        return a.title  <= b.title
                    }
                    if iterator == ids.count - 1 {
                        delegate.moviesArrived(movies)
                    }
                }
            }
        }
        
    }
    
    func reArrangeWatchList(from: Int, to: Int) {
        let id = watchList[from]
        watchList.removeAtIndex(from)
        watchList.insert(id, atIndex: to)
    }
    
    // public access to the cache system of the object.
    
    func knownMovie(id: String) -> Movie? {
        return knownMovies[id]
    }
    
    func knownPerson(id: String) -> Actor? {
        return knownActors[id]
    }
    
    func learnMovie(id: String, movie: Movie) {
        knownMovies[id] = movie
    }
    
    func learnPerson(id: String, actor: Actor) {
        knownActors[id] = actor
    }
    
}
