//
//  User.swift
//  Movies
//
//  Created by Mathias Quintero on 11/13/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Alamofire

class User: WatchListGetter {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let token: String
    var fetcher: MovieDataFetcher?
    var name: String
    var image: UIImage?
    var id: String
    var friends = [Person]()
    
    init(load: Bool) {
        name = ""
        token = FBSDKAccessToken.currentAccessToken().tokenString ?? ""
        id = ""
        languagePreference = LanguagePreference.NotCare
        distanceRange = 10
        if load {
            doRequest()
        }
    }
    
    convenience init(fetcher: MovieDataFetcher) {
        self.init(load: false)
        self.fetcher = fetcher
        fetcher.getter = self
        doRequest()
    }
    
    func doRequest() {
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields:":"name,id"])
        request.startWithCompletionHandler() { (_,result,_) -> Void in
            if let dictionary = result as? NSDictionary, username = dictionary["name"] as? String, userid = dictionary["id"] as? String {
                self.name = username
                self.id = userid
                self.getProfilePic()
                self.getPreferences()
                self.fetcher?.getDefaultsFromMemory()
            }
        }
    }
    
    var notifyWatchlist = true {
        didSet {
            if let url = ("https://moviesbackend.herokuapp.com/notifyWatch?pref=" + (notifyWatchlist ? "1" : "0")).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
                Alamofire.request(.PUT, url).authenticate(user: id, password: token)
            }
        }
    }
    
    var notifyArtist = true {
        didSet {
            if let url = ("https://moviesbackend.herokuapp.com/notifySub?pref=" + (notifyArtist ? "1" : "0")).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
                Alamofire.request(.PUT, url).authenticate(user: id, password: token)
            }
        }
    }
    
    var languagePreference: LanguagePreference {
        didSet {
            if let url = ("https://moviesbackend.herokuapp.com/language?pref=" + languagePreference.rawValue).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
                Alamofire.request(.PUT, url).authenticate(user: id, password: token)
            }
        }
    }
    
    var distanceRange: Int {
        didSet {
            if let url = ("https://moviesbackend.herokuapp.com/distance?userid=" + id + "&pref=" + distanceRange.description).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
                Alamofire.request(.PUT, url).authenticate(user: id, password: token)
            }
        }
    }
    
    func getSubscriptions(handler: ([Int]) -> ()) {
        let url = "https://moviesbackend.herokuapp.com/subs"
        Alamofire.request(.GET, url).authenticate(user: id, password: token).responseJSON() { (response) in
            var people = [Int]()
            if let body = response.result.value as? [AnyObject] {
                for item in body {
                    if let personID = item as? String, finalID = Int(personID) {
                        people.append(finalID)
                    }
                }
            }
            handler(people)
        }
    }
    
    func addSubscription(personID: Int) {
        if let url = ("https://moviesbackend.herokuapp.com/subs?person=" + personID.description).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
            Alamofire.request(.POST, url).authenticate(user: id, password: token)
        }
    }
    
    func removeSubscription(personID: Int) {
        if let url = ("https://moviesbackend.herokuapp.com/subs?person=" + personID.description).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
            Alamofire.request(.DELETE, url).authenticate(user: id, password: token)
        }
    }
    
    func getWatchList(handler: ([Int]) -> ()) {
        let url = "https://moviesbackend.herokuapp.com/watchlist"
        Alamofire.request(.GET, url).authenticate(user: id, password: token).responseJSON() { (response) in
            var movies = [Int]()
            if let body = response.result.value as? [AnyObject] {
                for item in body {
                    if let movieID = item as? String, finalMovieID = Int(movieID) {
                        movies.append(finalMovieID)
                    }
                }
            }
            handler(movies)
        }
    }
    
    func addToWatchList(movieID: Int) {
        if let url = ("https://moviesbackend.herokuapp.com/watchlist?movie=" + movieID.description).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
            Alamofire.request(.POST, url).authenticate(user: id, password: token)
        }
    }
    
    func removeFromWatchList(movieID: Int) {
        if let url = ("https://moviesbackend.herokuapp.com/watchlist?movie=" + movieID.description).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
            Alamofire.request(.DELETE, url).authenticate(user: id, password: token)
        }
    }
    
    func getPreferences() {
        let url = "https://moviesbackend.herokuapp.com/user"
        Alamofire.request(.GET, url).authenticate(user: id, password: token).responseJSON() { (response) in
            if let body = response.result.value as? [String:AnyObject], dist = body["maxDistanceForCinema"] as? String, pref = body["preferredLanguageSetting"] as? String, watchlistNot = body["notifyOnWatchList"] as? Bool, artistNot = body["notifyOnSubscription"] as? Bool {
                self.languagePreference = LanguagePreference.getPref(pref)
                self.distanceRange = Int(dist) ?? 10
                self.notifyArtist = artistNot
                self.notifyWatchlist = watchlistNot
            }
        }
    }
    
    func getProfilePic() {
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name,picture.height(150)"])
        request.startWithCompletionHandler() { (_,result,error) -> Void in
            if error == nil {
                if let dictionary = result as? NSDictionary,picture = dictionary["picture"] as? NSDictionary, pictureData = picture["data"] as? NSDictionary, url = pictureData["url"] as? String {
                    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue),0)) {
                        if let urlObject = NSURL(string: url), downloadedData = NSData(contentsOfURL: urlObject), downloadedImage = UIImage(data: downloadedData) {
                            self.image = downloadedImage
                        }
                    }
                }
            } else {
                print("Error!!")
                print(error)
            }
            
        }
    }
    
    func getFriends(handler: ([Person] -> ())) {
        if friends.isEmpty {
            let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields":"name,picture.height(150)"])
            request.startWithCompletionHandler() { (_,result,error) -> Void in
                if error == nil {
                    if let dictionary = result as? NSDictionary, friends = dictionary["data"] as? [AnyObject] {
                        for friend in friends {
                            if let data = friend as? [String:AnyObject], id = data["id"] as? String, name = data["name"] as? String, picture = data["picture"] as? [String:AnyObject], picturedata = picture["data"], url = picturedata["url"] as? String {
                                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue),0)) {
                                    if let urlObject = NSURL(string: url), downloadedData = NSData(contentsOfURL: urlObject), downloadedImage = UIImage(data: downloadedData) {
                                        let newFriend = Person(name: name, id: id, image: downloadedImage)
                                        self.friends.append(newFriend)
                                        self.friends.sortInPlace() { (first,second) in
                                            return first.name < second.name
                                        }
                                        handler(self.friends)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print("Error!!")
                    print(error)
                }
            }
        } else {
            handler(friends)
        }
    }
    
    func toPerson() -> Person {
        return Person(name: self.name, id: self.id, image: self.image)
    }
    
}
