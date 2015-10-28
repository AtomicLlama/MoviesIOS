//
//  MovieDataFetcher.swift
//  Movies
//
//  Created by Mathias Quintero on 10/18/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
import Alamofire

protocol MovieReceiverProtocol {
    func moviesArrived(newMovies: [Movie])
    func imageDownloaded()
}

class MovieDataFetcher: MovieInfoDataSource {
    
    var receiver: MovieReceiverProtocol?
    
    let newMoviesURLString = "https://api.themoviedb.org/3/movie/now_playing?api_key=18ec732ece653360e23d5835670c47a0"
    
    var knownActors = [String:Actor]()
    
    var knownMovies = [String:Movie]()
    
    func fetchNewMovies() {
        var movies = [Movie]()
        if let url = NSURL(string: newMoviesURLString) {
            Alamofire.request(.GET, url).responseJSON() { (response) in
                if let now = response.result.value as? [String:AnyObject], moviesAsJSON = now["results"] as? [AnyObject] {
                    for movie in moviesAsJSON {
                        if let movieAsDictionary = movie as? [String:AnyObject] {
                            if let id = movieAsDictionary["id"] as? Int, title = movieAsDictionary["title"] as? String, plot = movieAsDictionary["overview"] as? String, year = movieAsDictionary["release_date"] as? String, rating = movieAsDictionary["vote_average"] as? Double, poster = movieAsDictionary["poster_path"] as? String {
                                if let alreadyKnownMovie = self.knownMovies[id.description] {
                                    movies.append(alreadyKnownMovie)
                                } else {
                                    let yearOnly = year.componentsSeparatedByString("-")
                                    let newMovie = Movie(title: title, year: Int(yearOnly[0])!, rating: rating, description: plot, id: id.description, posterURL: "https://image.tmdb.org/t/p/w500" + poster, handler: self.receiver, dataSource: self)
                                    self.knownMovies[id.description] = newMovie
                                    movies.append(newMovie)
                                }
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.receiver?.moviesArrived(movies)
                    }
                }
            }
        }
        
    }
    
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
