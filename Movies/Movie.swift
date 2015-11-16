//
//  Movie.swift
//  Movies
//
//  Created by Mathias Quintero on 10/15/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

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
    func deleteFromWatchList(index: Int)
    func fetchTickets(requestingView: TicketReceiverProtocol)
    
}

class Movie {

    var delegate: MovieInfoDataSource?

    var subscribedControllers = [MovieReceiverProtocol]()

    let title: String
    var director: Actor
    let year: Int
    let rating: Double
    let description: String
    let id: String
    var actors: [(Actor, String)]
    var poster: UIImage?
    var trailerID: String?
    var netflixLink: String?
    var detailImage: UIImage?


    init(title: String, year: Int, rating: Double, description: String, id: String, posterURL: String, handler: MovieReceiverProtocol?, dataSource: MovieInfoDataSource?) {

        // Set Properties

        self.title = title
        self.year = year
        self.rating = rating
        self.description = description
        self.id = id
        actors = []
        delegate = dataSource
        director = Actor(director: "Tarantino")

        // Download Image on another queue

        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            if let url = NSURL(string: posterURL), dataFromImage = NSData(contentsOfURL: url), image = UIImage(data: dataFromImage) {
                self.poster = image
                dispatch_async(dispatch_get_main_queue()) {

                    // Return to main queue to update view

                    handler?.imageDownloaded()
                    self.notifySubscribers()
                }
                self.fetchActors()
            }
        }

    }
    
    func fetchDetailImage(subscriber: MovieReceiverProtocol) {
        
        if detailImage != nil {
            return
        }
        
        let url = "http://api.themoviedb.org/3/movie/" + id + "/images?api_key=18ec732ece653360e23d5835670c47a0"
        
        // Start request
        
        Alamofire.request(.GET, url).responseJSON() { (response) in
            
            if let body = response.result.value as? [String:AnyObject], backdrops = body["backdrops"] as? [AnyObject], firstImageObject = backdrops[0] as? [String:AnyObject], path = firstImageObject["file_path"] as? String {
                
                let imageURL = "https://image.tmdb.org/t/p/w500" + path
                
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                    if let url = NSURL(string: imageURL), dataFromImage = NSData(contentsOfURL: url), image = UIImage(data: dataFromImage) {
                        self.detailImage = image
                        dispatch_async(dispatch_get_main_queue()) {
                            subscriber.imageDownloaded()
                        }
                    }
                }
                
            }
            
        }

        
    }
    
    func isMovieInWatchList() -> Bool {
        return delegate?.isMovieInWatchList(Int(id) ?? -1) ?? false
    }
    
    func toggleMovieInWatchList() -> Bool {
        if let itemID = Int(id) {
            if (isMovieInWatchList()) {
                delegate?.removeFromWatchList(itemID)
                return false
            } else {
                delegate?.addToWatchList(itemID)
                return true
            }
        }
        return false
    }

    func notifySubscribers() {
        for view in self.subscribedControllers {

            //Alert all subscribers

            view.imageDownloaded()
        }
    }

    func subscribeToImage(controller: MovieReceiverProtocol) {

        //Add Subscribed View Controllers in case of a segue before the image has been downloaded.

        if poster == nil {
            subscribedControllers.append(controller)
        }

    }

    func getTrailerUrl(controller: MovieReceiverProtocol) {
        if trailerID == nil {
            let url = "http://api.themoviedb.org/3/movie/" + id + "/videos?api_key=18ec732ece653360e23d5835670c47a0"
            Alamofire.request(.GET, url).responseJSON() { (response) in
                if let dictionary = response.result.value as? [String:AnyObject], results = dictionary["results"] as? [AnyObject], trailer = results.first as? [String:AnyObject], videoID = trailer["key"] as? String {
                    self.trailerID = videoID
                    dispatch_async(dispatch_get_main_queue()) {
                        controller.imageDownloaded()
                    }
                }
            }
        }
    }

    func fetchActors() {

        // Makes a request for all the Actors in the movie  and picks the 5 most important

        // Create the right URL and reinitialize the actor array just in case

        actors = []
        let url = "http://api.themoviedb.org/3/movie/" + id + "/credits?api_key=18ec732ece653360e23d5835670c47a0"

        // Start request

        Alamofire.request(.GET, url).responseJSON() { (response) in

            //Get Cast Object in the JSON body as an array of dictionaries

            if let dictionary = response.result.value as? [String:AnyObject], cast = dictionary["cast"] as? [AnyObject], crew = dictionary["crew"] as? [AnyObject] {
                if (cast.count != 0) {

                    // Only read the first 5

                    for actor in cast[0...(min(max(cast.count-1,0), 4))] {

                        // Get the actor as a dictionary to read the properties of the SubObject

                        if let actorAsDictionary = actor as? [String:AnyObject] {

                            // Get the properties of the actor

                            if let name = actorAsDictionary["name"] as? String, character = actorAsDictionary["character"] as? String, actorID = actorAsDictionary["id"] as? Int {

                                // Define the picture as an optional

                                let pic = actorAsDictionary["profile_path"] as? String

                                // Check if the actor was already cached, if not create the Object of the Actor

                                if let actorKnown = self.delegate?.knownPerson(actorID.description) {
                                    self.actors.append(actorKnown, character)
                                } else {

                                    // Create Actor Object, add to cache Dictionary and add him to the actor array

                                    let actorAsObject: Actor
                                    if let picURL = pic {
                                        actorAsObject = Actor(name: name, pic: "https://image.tmdb.org/t/p/w185" + picURL, id: actorID.description, delegate: self.delegate)
                                    } else {
                                        actorAsObject = Actor(name: name, pic: nil, id: actorID.description, delegate: self.delegate)
                                    }
                                    self.actors.append((actorAsObject, character))
                                    self.delegate?.learnPerson(actorID.description, actor: actorAsObject)
                                }
                            }
                        }
                    }
                }
                if crew.count != 0 {
                    for member in crew {
                        if let crewMemberAsDictionary = member as? [String:AnyObject], jobTitle = crewMemberAsDictionary["job"] as? String {
                            if jobTitle == "Director" {
                                if let name = crewMemberAsDictionary["name"] as? String, personID = crewMemberAsDictionary["id"] as? Int {
                                    let pic = crewMemberAsDictionary["profile_path"] as? String
                                    if let memberKnown = self.delegate?.knownPerson(personID.description) {
                                        self.director = memberKnown
                                    } else {
                                        let memberAsObject: Actor
                                        if let picURL = pic {
                                            memberAsObject = Actor(name: name, pic: "https://image.tmdb.org/t/p/w185" + picURL, id: personID.description, delegate: self.delegate)
                                        } else {
                                            memberAsObject = Actor(name: name, pic: nil, id: personID.description, delegate: self.delegate)
                                        }
                                        self.director = memberAsObject
                                        self.delegate?.learnPerson(personID.description, actor: memberAsObject)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                print("Error Unwrapping cast" + (response.result.value?.description ?? "Nothing!"))

                // Check if the problem was that too many request were made, if so: make the request again, until it works.

                if let data = response.result.value as? [String:AnyObject], status = data["status"] as? Int {
                    if status == 25 {
                        self.fetchActors()
                    }
                }
            }
        }
    }
}
