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
import ObjectMapper
import AlamofireObjectMapper

class Movie: Mappable {

    var delegate: MovieInfoDataSource?

    var subscribedControllers = [MovieReceiverProtocol]()

    var title = "No Title Available"
    var director = Actor(director: "No Director Available")
    var year = 1970
    var rating = 10.0
    var description = "No Description Available"
    var id = 0
    var actors = [(Actor, String)]()
    var poster: UIImage?
    var trailerID: String?
    var netflixLink: String?
    var detailImage: UIImage?
    var releaseDate = NSDate() {
        didSet {
            let calendar = NSCalendar.currentCalendar()
            let dateComponents = calendar.components(NSCalendarUnit.Year, fromDate: releaseDate)
            year = dateComponents.year
        }
    }
    
    var streamingLinks = [(String, String)]()
    var linksLoaded = false
    
    var movieTimes = [String:[Showtime]]()
    
    func getTimesForDate(date: NSDate) -> [Showtime] {
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy MM dd"
        return movieTimes[dateformatter.stringFromDate(date)] ?? []
    }
    
    func addTime(time: Showtime) {
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy MM dd"
        if movieTimes[dateformatter.stringFromDate(time.time)] != nil {
            movieTimes[dateformatter.stringFromDate(time.time)]?.append(time)
        } else {
            movieTimes[dateformatter.stringFromDate(time.time)] = [time]
        }
    }
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        title <- map["original_title"]
        description <- map["overview"]
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy-mm-dd"
        dateformatter.timeZone = NSTimeZone.defaultTimeZone()
        releaseDate <- (map["release_date"], DateFormatterTransform(dateFormatter: dateformatter))
        id <- map["id"]
        rating <- map["vote_average"]
        if let path = map.JSONDictionary["poster_path"] as? String {
            let url = "https://image.tmdb.org/t/p/w150" + path
            ImageDownloadManager.getImageInURL(url) { (image) in
                self.poster = image
                self.notifySubscribers()
            }
        }
        
    }
    
    func fetchDetailImage(subscriber: MovieReceiverProtocol) {
        
        if detailImage != nil {
            return
        }
        
        let url = "http://api.themoviedb.org/3/movie/" + id.description + "/images?api_key=18ec732ece653360e23d5835670c47a0"
        
        // Start request
        
        Alamofire.request(.GET, url).responseJSON() { (response) in
            
            if let body = response.result.value as? [String:AnyObject], backdrops = body["backdrops"] as? [AnyObject], firstImageObject = backdrops.first as? [String:AnyObject], path = firstImageObject["file_path"] as? String {
                
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
    
    func fetchStreamingLinks(handler: () -> ()) {
        if !linksLoaded {
            let url = "https://moviesbackend.herokuapp.com/streaming/" + id.description
            Alamofire.request(.GET, url).responseJSON() { (response) in
                if let links = response.result.value as? [AnyObject] {
                    for item in links {
                        if let data = item as? [String:AnyObject], service = data["service"] as? String, link = data["link"] as? String {
                            self.streamingLinks.append((service, link))
                        }
                    }
                }
                self.linksLoaded = true
                handler()
            }
        } else {
            handler()
        }
    }
    
    func isMovieInWatchList() -> Bool {
        return delegate?.isMovieInWatchList(Int(id) ?? -1) ?? false
    }
    
    func toggleMovieInWatchList() -> Bool {
        if (isMovieInWatchList()) {
            delegate?.removeFromWatchList(id)
            return false
        } else {
            delegate?.addToWatchList(id)
            return true
        }
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
            let url = "http://api.themoviedb.org/3/movie/" + id.description + "/videos?api_key=18ec732ece653360e23d5835670c47a0"
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

    func fetchActors(receiver: MovieActorsReceiver, all: Bool) {
        if !actors.isEmpty && !all {
            receiver.actorsFetched()
            return
        }
        actors = []
        let url = "http://api.themoviedb.org/3/movie/" + id.description + "/credits?api_key=18ec732ece653360e23d5835670c47a0"
        Alamofire.request(.GET, url).responseJSON() { (response) in
            if let dictionary = response.result.value as? [String:AnyObject],
                    cast = dictionary["cast"] as? [AnyObject],
                    crew = dictionary["crew"] as? [AnyObject] {
                let lastIndex = all ? cast.count-1 : (min(max(cast.count-1,0), 4))
                for actor in cast[0...lastIndex] {
                    if let actorAsDictionary = actor as? [String:AnyObject], character = actorAsDictionary["character"] as? String, id = actorAsDictionary["id"] as? Int {
                        if let actorKnown = self.delegate?.knownPerson(id.description) {
                            self.actors.append(actorKnown, character)
                        } else {
                            if let actor = Mapper<Actor>().map(actorAsDictionary) {
                                self.actors.append((actor, character))
                                self.delegate?.learnPerson(id.description, actor: actor)
                            }
                        }
                    }
                }
                receiver.actorsFetched()
                if !crew.isEmpty {
                    for member in crew {
                        if let crewMemberAsDictionary = member as? [String:AnyObject],
                                jobTitle = crewMemberAsDictionary["job"] as? String,
                                id = crewMemberAsDictionary["id"] as? Int {
                            if jobTitle == "Director" {
                                if let actorKnown = self.delegate?.knownPerson(id.description) {
                                    self.actors.append(actorKnown, jobTitle)
                                } else {
                                    if let actor = Mapper<Actor>().map(crewMemberAsDictionary) {
                                        self.director = actor
                                        self.delegate?.learnPerson(id.description, actor: actor)
                                    }
                                }
                                break
                            }
                        }
                    }
                }
            } else {
                if let data = response.result.value as? [String:AnyObject], status = data["status"] as? Int {
                    if status == 25 {
                        self.fetchActors(receiver, all: all)
                    }
                }
            }
        }
    }
}
