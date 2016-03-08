//
//  MovieDataFetcher.swift
//  Movies
//
//  Created by Mathias Quintero on 10/18/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
import Alamofire

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
    
    let newMoviesURLString = "https://api.themoviedb.org/3/movie/now_playing?api_key=18ec732ece653360e23d5835670c47a0"
    
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
        
        //Initialize empty array and make request for now in theatres
        
        var movies = [Movie]()
            Alamofire.request(.GET, newMoviesURLString).responseJSON() { (response) in
                
                //Fetch Todays Movies and get the array of results on body.results
                
                if let now = response.result.value as? [String:AnyObject], moviesAsJSON = now["results"] as? [AnyObject] {
                    
                    //Iterate through the array
                    
                    for movie in moviesAsJSON {
                        
                        //Cast object as a JSON Object to be interpreted as a dictionary
                        
                        if let movieAsDictionary = movie as? [String:AnyObject] {
                            
                            //Get data from object
                            
                            if let id = movieAsDictionary["id"] as? Int, title = movieAsDictionary["title"] as? String, plot = movieAsDictionary["overview"] as? String, year = movieAsDictionary["release_date"] as? String, rating = movieAsDictionary["vote_average"] as? Double, poster = movieAsDictionary["poster_path"] as? String {
                                
                                //Check if movie was cached. If so get the cached version, to favor processing and internet usage.
                                
                                if let alreadyKnownMovie = self.knownMovies[id.description] {
                                    movies.append(alreadyKnownMovie)
                                } else {
                                    
                                    //If movie is not cached create the object, download the image and add it to our cache.
                                    
                                    let yearOnly = year.componentsSeparatedByString("-")
                                    let newMovie = Movie(title: title, year: Int(yearOnly[0])!, rating: rating, description: plot, id: id.description, posterURL: poster, handler: self.receiver, dataSource: self)
                                    self.knownMovies[id.description] = newMovie
                                    movies.append(newMovie)
                                    if self.tickets.count < 3 {
                                        self.tickets.append(Ticket(movie: newMovie))
                                    }
                                }
                            }
                        }
                    }
                    
                    //Get back to the main queue to update the receiving view. (Probably a TableView)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.receiver?.moviesArrived(movies)
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
        if !ids.isEmpty {
            for iterator in 0...(ids.count - 1) {
                if let alreadyKnownActor = self.knownActors[ids[iterator].description] {
                    actors.append(alreadyKnownActor)
                    if iterator == ids.count - 1 {
                        actors.sortInPlace() { (a,b) in
                            return a.name <= b.name
                        }
                        delegate.receiveActors(actors)
                    }
                } else {
                    Alamofire.request(.GET, getActorURL(ids[iterator])).responseJSON() { (response) in
                        if let actorAsDictionary = response.result.value as? [String:AnyObject] {
                            if let name = actorAsDictionary["name"] as? String, actorID = actorAsDictionary["id"] as? Int {
                                let pic = actorAsDictionary["profile_path"] as? String
                                if let actorKnown = self.knownActors[actorID.description] {
                                    actors.append(actorKnown)
                                } else {
                                    let actorAsObject: Actor
                                    if let picURL = pic {
                                        actorAsObject = Actor(name: name, pic: "https://image.tmdb.org/t/p/w185" + picURL, id: actorID.description, delegate: self)
                                    } else {
                                        actorAsObject = Actor(name: name, pic: nil, id: actorID.description, delegate: self)
                                    }
                                    actors.append(actorAsObject)
                                    self.knownActors[actorID.description] = actorAsObject
                                }
                                actors.sortInPlace() { (a,b) in
                                    return a.name <= b.name
                                }
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                delegate.receiveActors(actors)
                            }
                        }
                    }
                }
            }
            
        } else {
            delegate.receiveActors([])
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
        
        if !ids.isEmpty {
            for iterator in 0...(ids.count - 1) {
                
                //Fetch every movie in the array of ids
                
                if let alreadyKnownMovie = self.knownMovies[ids[iterator].description] {
                    movies.append(alreadyKnownMovie)
                    movies.sortInPlace() { (a,b) in
                        return a.title  <= b.title
                    }
                    if iterator == ids.count - 1 {
                        delegate.moviesArrived(movies)
                    }
                } else {
                    Alamofire.request(.GET, getMovieURL(ids[iterator])).responseJSON() { (response) in
                        
                        // Get Movie Object
                        
                        if let movieAsDictionary = response.result.value as? [String:AnyObject] {
                            
                            //Get data from movie
                            
                            if let id = movieAsDictionary["id"] as? Int, title = movieAsDictionary["title"] as? String, plot = movieAsDictionary["overview"] as? String, year = movieAsDictionary["release_date"] as? String, rating = movieAsDictionary["vote_average"] as? Double, poster = movieAsDictionary["poster_path"] as? String {
                                
                                //Check if movie is cached
                                
                                if let alreadyKnownMovie = self.knownMovies[id.description] {
                                    alreadyKnownMovie.subscribeToImage(delegate)
                                    movies.append(alreadyKnownMovie)
                                } else {
                                    
                                    //Create Movie Object!
                                    
                                    let yearOnly = year.componentsSeparatedByString("-")
                                    let newMovie = Movie(title: title, year: Int(yearOnly[0])!, rating: rating, description: plot, id: id.description, posterURL: poster, handler: delegate, dataSource: self)
                                    self.knownMovies[id.description] = newMovie
                                    movies.append(newMovie)
                                }
                                movies.sortInPlace() { (a,b) in
                                    return a.title  <= b.title
                                }
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                delegate.moviesArrived(movies)
                            }
                        }
                        
                        //Send movie at the end to the receiving view!
                        
                        
                    }
                }
                
            }
        } else {
            delegate.moviesArrived([])
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
