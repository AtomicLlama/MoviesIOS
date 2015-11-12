//
//  Actor.swift
//  Movies
//
//  Created by Mathias Quintero on 10/16/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import Alamofire

protocol ActorFetchDataReceiver {
    func receiveMoviesFromActor(movies: Movie)
    func receiverOfImage() -> MovieReceiverProtocol?
}

class Actor {
    
    // Directors are also listed as Actors
    
    let name: String
    var headshot: UIImage?
    var bio: String
    let id: String
    var fetcher: MovieDataFetcher?
    
    var delegate: MovieInfoDataSource?
    
    var receivingView: ActorFetchDataReceiver?
    
    func fetchMovies(receivingView: ActorFetchDataReceiver) {
        
        // Will fetch the movies of an actor (for now it's for the Actor Detail View)
        
        // Create valid URL and make a request
        
        let url = "http://api.themoviedb.org/3/person/" + self.id + "/movie_credits?api_key=18ec732ece653360e23d5835670c47a0"
        Alamofire.request(.GET, url).responseJSON() { (response) in
            
            // Get array of roles for the actor and iterate the first 10
            
            if let dictionary = response.result.value as? [String:AnyObject], cast = dictionary["cast"] as? [AnyObject], crew = dictionary["crew"] as? [AnyObject] {
                let arrayToIterate: [AnyObject]
                if crew.count > cast.count {
                    arrayToIterate = crew
                } else {
                    arrayToIterate = cast
                }
                for role in arrayToIterate[0...(min(arrayToIterate.count-1, 9))] {
                    
                    
                    // Get ID of the movie to create a valid URL for the data of the movie
                    
                    if let roleAsDictionary = role as? [String:AnyObject], movieID = roleAsDictionary["id"] as? Int {
                        let movieURL = "http://api.themoviedb.org/3/movie/" + movieID.description + "?api_key=18ec732ece653360e23d5835670c47a0"
                        
                        // Request information for that ID
                        
                        Alamofire.request(.GET, movieURL).responseJSON() { (response) in
                            
                            // Get data from movie
                            
                            if let movieAsDictionary = response.result.value as? [String:AnyObject], title = movieAsDictionary["title"] as? String, plot = movieAsDictionary["overview"] as? String, year = movieAsDictionary["release_date"] as? String, rating = movieAsDictionary["vote_average"] as? Double, poster = movieAsDictionary["poster_path"] as? String {
                                
                                // Check if the movie has been cached. If not create the object.
                                
                                if let alreadyKnownMovie = self.delegate?.knownMovie(movieID.description) {
                                    
                                    // Switch to the Main Queue to update the view with the cached movie
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                        receivingView.receiveMoviesFromActor(alreadyKnownMovie)
                                    }
                                    
                                } else {
                                    
                                    // Create object and send to the View that asked for it.
                                    
                                    let yearOnly = year.componentsSeparatedByString("-")
                                    let newMovie = Movie(title: title, year: Int(yearOnly[0]) ?? 1970, rating: rating, description: plot, id: movieID.description, posterURL: "https://image.tmdb.org/t/p/w500" + poster, handler: receivingView.receiverOfImage(), dataSource: self.delegate)
                                    newMovie.fetcher = self.fetcher
                                    self.delegate?.learnMovie(movieID.description, movie: newMovie)
                                    
                                    // Switch to the Main Queue to update the view with the new movie
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                        receivingView.receiveMoviesFromActor(newMovie)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    init(name: String, pic: String?, id: String, delegate: MovieInfoDataSource?) {
        self.name = name
        self.id = id
        bio = "No Bio Info Available"
        self.delegate = delegate
        
        // Download profile picture of the actor
        
        if let picURL = pic {
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                if let url = NSURL(string: picURL), dataFromImage = NSData(contentsOfURL: url), image = UIImage(data: dataFromImage) {
                    self.headshot = image
                }
            }
        }
        
        // Get Bio from wikipedia
        
        // Create url String with only allowed characters, encoding as URL Allowed Characters
        
        if let actorUrl = ("https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=" + name.stringByReplacingOccurrencesOfString(" ", withString: "+")).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
            
            // Make request
            
            Alamofire.request(.GET, actorUrl).responseJSON() { (response) in
                
                // Get the pages object
                
                if let batch = response.result.value as? [String:AnyObject], query = batch["query"] as? [String:AnyObject], pages = query["pages"] as? [String:AnyObject] {
                    
                    // Iterate through the pages (Even if we only need one) To get the first result and break
                    
                    // This has to be done since wikipedia doesn't encode the pages as an array but a dictionary with the ids of the queries as keys
                    
                    for (_, actor) in pages {
                        if let actorData = actor as? [String:AnyObject] {
                            
                            // Only take the first paragraph
                            
                            self.bio = (actorData["extract"] as? String ?? "No Biography Available").componentsSeparatedByString("\n")[0]
                        }
                        break
                    }
                } else {
                    print("Error. No Biography Data Available " + (response.result.value?.description ?? "Nothing!"))
                }
            }
        }
    }
    
    init(director: String) {
        name = director
        bio = "Quentin Jerome Tarantino was born in Knoxville, Tennessee, to Connie (McHugh), a nurse, and Tony Tarantino, an Italian-American actor and musician from New York."
        headshot = UIImage(named: "director")
        id = "138"
    }
    
}