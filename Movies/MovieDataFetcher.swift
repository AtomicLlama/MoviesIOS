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
    func receiveActors(_ actors: [Actor])
}

class MovieDataFetcher: MovieInfoDataSource {
    
    let defaults = UserDefaults.standard
    
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
        Alamofire.request(newMoviesURLString).responseArray() { (response: DataResponse<[Movie]>) in
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
                DispatchQueue.main.async {
                    self.receiver?.moviesArrived(movies)
                }
            } else {
                DispatchQueue.main.async {
                    self.receiver?.moviesArrived([])
                }
            }
        }
        
    }
    
    func fetchTickets(_ requestingView: TicketReceiverProtocol) {
        requestingView.receiveTickets(tickets)
    }
    
    func addToSubscriptions(_ id: Int) {
        subs.append(id)
        getter?.addSubscription(id)
    }
    
    func removeFromSubscriptions(_ id: Int) {
        getter?.removeSubscription(id)
        subs = subs.filter() { item in
            return item != id
        }
    }
    
    func addToWatchList(_ id: Int) {
        watchList.append(id)
        getter?.addToWatchList(id)
    }
    
    func removeFromWatchList(_ id: Int) {
        getter?.removeFromWatchList(id)
        watchList = watchList.filter() { item in
            return item != id
        }
    }
    
    func isMovieInWatchList(_ id: Int) -> Bool {
        return watchList.contains(id)
    }
    
    func isActorInSubscriptions(_ id: Int) -> Bool {
        return subs.contains(id)
    }
    
    func getListOfMovies(_ delegate: MovieReceiverProtocol) {
        getMoviesForWatchList(watchList, delegate: delegate)
    }
    
    func getActorsFromSubscriptions(_ delegate: ActorReceiverProtocol) {
        getListOfActors(subs, delegate: delegate)
    }
    
    func getListOfActors(_ ids: [Int], delegate: ActorReceiverProtocol) {
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
                    actors.sort() { (a,b) in
                        return a.name <= b.name
                    }
                    delegate.receiveActors(actors)
                }
            } else {
                Alamofire.request(getActorURL(ids[iterator])).responseObject() { (response: DataResponse<Actor>) in
                    if let actor = response.result.value {
                        actors.append(actor)
                        actors.sort { (a,b) in
                            return a.name <= b.name
                        }
                        DispatchQueue.main.async {
                            delegate.receiveActors(actors)
                        }
                    }
                }
            }
        }
    }
    
    func getMovieURL(_ id: Int) -> String {
        return "http://api.themoviedb.org/3/movie/" + id.description + "?api_key=18ec732ece653360e23d5835670c47a0"
    }
    
    func getActorURL(_ id: Int) -> String {
        return "http://api.themoviedb.org/3/person/" + id.description + "?api_key=18ec732ece653360e23d5835670c47a0"
    }
    
    func getMoviesForWatchList(_ ids: [Int], delegate: MovieReceiverProtocol) {
        if ids.count == 0 {
            delegate.moviesArrived([])
            return
        }
        watchlistSubscriber = delegate
        var movies = [Movie]()
        for iterator in 0..<ids.count {
            if let alreadyKnownMovie = self.knownMovies[ids[iterator].description] {
                movies.append(alreadyKnownMovie)
                movies.sort() { (a,b) in
                    return a.title  <= b.title
                }
                if iterator == ids.count - 1 {
                    delegate.moviesArrived(movies)
                }
            } else {
                Alamofire.request(getMovieURL(ids[iterator])).responseObject() { (response: DataResponse<Movie>) in
                    if let movie = response.result.value {
                        self.learnMovie(movie.id.description, movie: movie)
                        movies.append(movie)
                    }
                    movies.sort() { (a,b) in
                        return a.title  <= b.title
                    }
                    if iterator == ids.count - 1 {
                        delegate.moviesArrived(movies)
                    }
                }
            }
        }
        
    }
    
    func reArrangeWatchList(_ from: Int, to: Int) {
        let id = watchList[from]
        watchList.remove(at: from)
        watchList.insert(id, at: to)
    }
    
    // public access to the cache system of the object.
    
    func knownMovie(_ id: String) -> Movie? {
        return knownMovies[id]
    }
    
    func knownPerson(_ id: String) -> Actor? {
        return knownActors[id]
    }
    
    func learnMovie(_ id: String, movie: Movie) {
        knownMovies[id] = movie
    }
    
    func learnPerson(_ id: String, actor: Actor) {
        knownActors[id] = actor
    }
    
}
