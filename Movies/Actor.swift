//
//  Actor.swift
//  Movies
//
//  Created by Mathias Quintero on 10/16/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class Actor: Mappable {
    
    // Directors are also listed as Actors
    
    var name = "No Name Available"
    var headshot: UIImage?
    var bio = "No Biography Available"
    var id = 0
    var movies: [Movie]?
    var delegate: MovieInfoDataSource?
    var receivingView: MovieReceiverProtocol?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        if let profilePath = map.JSON["profile_path"] as? String {
            let url = "https://image.tmdb.org/t/p/w185" + profilePath
            ImageDownloadManager.getImageInURL(url) { (image) in
                self.headshot = image
            }
        }
        getBio()
    }
    
    func getBio() {
        if let actorUrl = ("https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=" + name.replacingOccurrences(of: " ", with: "+")).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
            Alamofire.request(actorUrl).responseJSON() { (response) in
                if let batch = response.result.value as? [String:AnyObject], let query = batch["query"] as? [String:AnyObject], let pages = query["pages"] as? [String:AnyObject] {
                    for (_, actor) in pages {
                        if let actorData = actor as? [String:AnyObject] {
                            self.bio = (actorData["extract"] as? String ?? "No Biography Available").components(separatedBy: "\n")[0]
                        }
                        break
                    }
                } else {
                    print("Error. No Biography Data Available " + ((response.result.value as AnyObject).description ?? "Nothing!"))
                }
            }
        }
    }
    
    func fetchMovies(_ receivingView: MovieReceiverProtocol, all: Bool) {
        
        if movies != nil && (movies?.count ?? 0 > 5 || !all) {
            receivingView.moviesArrived(movies ?? [])
        }
        
        movies = []
        
        let url = "http://api.themoviedb.org/3/person/" + self.id.description + "/movie_credits?api_key=18ec732ece653360e23d5835670c47a0"
        Alamofire.request(url).responseJSON() { (response) in
            
            if let dictionary = response.result.value as? [String:AnyObject], let cast = dictionary["cast"] as? [AnyObject], let crew = dictionary["crew"] as? [AnyObject] {
                let arrayToIterate: [AnyObject]
                if crew.count > cast.count {
                    arrayToIterate = crew
                } else {
                    arrayToIterate = cast
                }
                let lastIndex = all ? arrayToIterate.count - 1 : (min(arrayToIterate.count-1, 4))
                let movieIds = arrayToIterate[0...lastIndex].map() { ($0 as? [String:AnyObject])?["id"] as? Int }.flatMap({ $0 })
                for id in movieIds {
                    if let knownMovie = self.delegate?.knownMovie(id.description) {
                        self.movies?.append(knownMovie)
                        receivingView.moviesArrived(self.movies ?? [])
                    } else {
                        Alamofire.request("http://api.themoviedb.org/3/movie/" + id.description + "?api_key=18ec732ece653360e23d5835670c47a0").responseObject() { (response: DataResponse<Movie>) in
                            if let movie = response.result.value {
                                self.delegate?.learnMovie(movie.id.description, movie: movie)
                                self.movies?.append(movie)
                                receivingView.moviesArrived(self.movies ?? [])
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    func isActorInSubscriptions() -> Bool {
        return delegate?.isActorInSubscriptions(id) ?? false
    }
    
    func toggleActorInSubscriptions() -> Bool {
        if (isActorInSubscriptions()) {
            delegate?.removeFromSubscriptions(id)
            return false
        } else {
            delegate?.addToSubscriptions(id)
            return true
        }
    }
    
    init(director: String) {
        name = director
        bio = "Quentin Jerome Tarantino was born in Knoxville, Tennessee, to Connie (McHugh), a nurse, and Tony Tarantino, an Italian-American actor and musician from New York."
        headshot = UIImage(named: "director")
        id = 138
    }
    
}
