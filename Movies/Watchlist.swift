//
//  Watchlist.swift
//  Movies
//
//  Created by Mathias Quintero on 10/20/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import Alamofire

class Watchlist: MovieDataFetcher {
    
    var movies = [Movie]()
    
    func getMovies(ids: [Int]) {
        
        //Reinitialize array
        
        movies = []
        
        for iterator in 0...(ids.count - 1) {
            
            //Fetch every movie in the array of ids
            
            Alamofire.request(.GET, getMovieURL(ids[iterator])).responseJSON() { (response) in
                
                // Get Movie Object
                
                if let movieAsDictionary = response.result.value as? [String:AnyObject] {
                    
                    //Get data from movie
                    
                    if let id = movieAsDictionary["id"] as? Int, title = movieAsDictionary["title"] as? String, plot = movieAsDictionary["overview"] as? String, year = movieAsDictionary["release_date"] as? String, rating = movieAsDictionary["vote_average"] as? Double, poster = movieAsDictionary["poster_path"] as? String {
                        
                        //Check if movie is cached
                        
                        if let alreadyKnownMovie = self.knownMovies[id.description] {
                            self.movies.append(alreadyKnownMovie)
                        } else {
                            
                            //Create Movie Object!
                            
                            let yearOnly = year.componentsSeparatedByString("-")
                            let newMovie = Movie(title: title, year: Int(yearOnly[0])!, rating: rating, description: plot, id: id.description, posterURL: "https://image.tmdb.org/t/p/w500" + poster, handler: self.receiver, dataSource: self)
                            self.knownMovies[id.description] = newMovie
                            self.movies.append(newMovie)
                        }
                    }
                }
                
                //Send movie at the end to the receiving view!
                
                dispatch_async(dispatch_get_main_queue()) {
                    if iterator == ids.count - 1 {
                        self.receiver?.moviesArrived(self.movies)
                    }
                }
            }
        }
    }
    
    func getListOfMovies(delegate: MovieReceiverProtocol) {
        
        //Get movies in the WatchList
        
        receiver = delegate
        
        // Do Parsing of PList or XML file here or fetch from our backend.
        
        getMovies([286217,99861,206647,140607])
    }
    
    func getMovieURL(id: Int) -> String{
        return "http://api.themoviedb.org/3/movie/" + id.description + "?api_key=18ec732ece653360e23d5835670c47a0"
    }
    
}