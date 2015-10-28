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
        
        movies = []
        
        for iterator in 0...(ids.count - 1) {
            
            Alamofire.request(.GET, getMovieURL(ids[iterator])).responseJSON() { (response) in
                if let movieAsDictionary = response.result.value as? [String:AnyObject] {
                    if let id = movieAsDictionary["id"] as? Int, title = movieAsDictionary["title"] as? String, plot = movieAsDictionary["overview"] as? String, year = movieAsDictionary["release_date"] as? String, rating = movieAsDictionary["vote_average"] as? Double, poster = movieAsDictionary["poster_path"] as? String {
                        if let alreadyKnownMovie = self.knownMovies[id.description] {
                            self.movies.append(alreadyKnownMovie)
                        } else {
                            let yearOnly = year.componentsSeparatedByString("-")
                            let newMovie = Movie(title: title, year: Int(yearOnly[0])!, rating: rating, description: plot, id: id.description, posterURL: "https://image.tmdb.org/t/p/w500" + poster, handler: self.receiver, dataSource: self)
                            self.knownMovies[id.description] = newMovie
                            self.movies.append(newMovie)
                        }
                    }
                }
                if iterator == ids.count - 1 {
                    self.receiver?.moviesArrived(self.movies)
                }
            }
        }
    }
    
    func getListOfMovies(delegate: MovieReceiverProtocol) {
        receiver = delegate
        
        // Do Parsing of PList or XML file here
        
        getMovies([286217,99861,206647,140607])
    }
    
    func getMovieURL(id: Int) -> String{
        return "http://api.themoviedb.org/3/movie/" + id.description + "?api_key=18ec732ece653360e23d5835670c47a0"
    }
    
}