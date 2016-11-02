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
    
    let defaults = UserDefaults.standard
    let token: String
    var fetcher: MovieDataFetcher?
    var name: String
    var image: UIImage?
    var id: String
    var friends = [Person]()
    
    init(load: Bool) {
        name = ""
        token = FBSDKAccessToken.current().tokenString ?? ""
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
        request?.start() { (_,result,_) -> Void in
            if let dictionary = result as? NSDictionary, let username = dictionary["name"] as? String, let userid = dictionary["id"] as? String {
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
            if let url = ("https://moviesbackend.herokuapp.com/notifyWatch?pref=" + (notifyWatchlist ? "1" : "0")).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
                Alamofire.request(url, method: .put).authenticate(user: id, password: token)
            }
        }
    }
    
    var notifyArtist = true {
        didSet {
            if let url = ("https://moviesbackend.herokuapp.com/notifySub?pref=" + (notifyArtist ? "1" : "0")).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
                Alamofire.request(url, method: .put).authenticate(user: id, password: token)
            }
        }
    }
    
    var languagePreference: LanguagePreference {
        didSet {
            if let url = ("https://moviesbackend.herokuapp.com/language?pref=" + languagePreference.rawValue).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
                Alamofire.request(url, method: .put).authenticate(user: id, password: token)
            }
        }
    }
    
    var distanceRange: Int {
        didSet {
            if let url = ("https://moviesbackend.herokuapp.com/distance?userid=" + id + "&pref=" + distanceRange.description).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
                Alamofire.request(url, method: .put).authenticate(user: id, password: token)
            }
        }
    }
    
    func getSubscriptions(_ handler: @escaping ([Int]) -> ()) {
        let url = "https://moviesbackend.herokuapp.com/subs"
        Alamofire.request(url).authenticate(user: id, password: token).responseJSON() { (response) in
            var people = [Int]()
            if let body = response.result.value as? [AnyObject] {
                for item in body {
                    if let personID = item as? String, let finalID = Int(personID) {
                        people.append(finalID)
                    }
                }
            }
            handler(people)
        }
    }
    
    func addSubscription(_ personID: Int) {
        if let url = ("https://moviesbackend.herokuapp.com/subs?person=" + personID.description).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
            Alamofire.request(url, method: .post).authenticate(user: id, password: token)
        }
    }
    
    func removeSubscription(_ personID: Int) {
        if let url = ("https://moviesbackend.herokuapp.com/subs?person=" + personID.description).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
            Alamofire.request(url, method: .delete).authenticate(user: id, password: token)
        }
    }
    
    func getWatchList(_ handler: @escaping ([Int]) -> ()) {
        let url = "https://moviesbackend.herokuapp.com/watchlist"
        Alamofire.request(url).authenticate(user: id, password: token).responseJSON() { (response) in
            var movies = [Int]()
            if let body = response.result.value as? [AnyObject] {
                for item in body {
                    if let movieID = item as? String, let finalMovieID = Int(movieID) {
                        movies.append(finalMovieID)
                    }
                }
            }
            handler(movies)
        }
    }
    
    func addToWatchList(_ movieID: Int) {
        if let url = ("https://moviesbackend.herokuapp.com/watchlist?movie=" + movieID.description).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
            Alamofire.request(url, method: .post).authenticate(user: id, password: token)
        }
    }
    
    func removeFromWatchList(_ movieID: Int) {
        if let url = ("https://moviesbackend.herokuapp.com/watchlist?movie=" + movieID.description).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
            Alamofire.request(url, method: .delete).authenticate(user: id, password: token)
        }
    }
    
    func getPreferences() {
        let url = "https://moviesbackend.herokuapp.com/user"
        Alamofire.request(url).authenticate(user: id, password: token).responseJSON() { (response) in
            if let body = response.result.value as? [String:AnyObject], let dist = body["maxDistanceForCinema"] as? String, let pref = body["preferredLanguageSetting"] as? String, let watchlistNot = body["notifyOnWatchList"] as? Bool, let artistNot = body["notifyOnSubscription"] as? Bool {
                self.languagePreference = LanguagePreference.getPref(pref)
                self.distanceRange = Int(dist) ?? 10
                self.notifyArtist = artistNot
                self.notifyWatchlist = watchlistNot
            }
        }
    }
    
    func getProfilePic() {
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name,picture.height(150)"])
        _ = request?.start() { (_,result,error) -> Void in
            if error == nil {
                if let dictionary = result as? NSDictionary,let picture = dictionary["picture"] as? NSDictionary, let pictureData = picture["data"] as? NSDictionary, let url = pictureData["url"] as? String {
                    let queue = DispatchQueue(label: "io.popcorn", qos: .userInitiated, target: nil)
                    queue.async {
                        if let urlObject = URL(string: url), let downloadedData = try? Data(contentsOf: urlObject), let downloadedImage = UIImage(data: downloadedData) {
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
    
    func getFriends(_ handler: @escaping (([Person]) -> ())) {
        if friends.isEmpty {
            let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields":"name,picture.height(150)"])
            _ = request?.start() { (_,result,error) -> Void in
                if error == nil {
                    if let dictionary = result as? NSDictionary, let friends = dictionary["data"] as? [AnyObject] {
                        for friend in friends {
                            if let data = friend as? [String:AnyObject], let id = data["id"] as? String, let name = data["name"] as? String, let picture = data["picture"] as? [String:AnyObject], let picturedata = picture["data"], let url = picturedata["url"] as? String {
                                let queue = DispatchQueue(label: "io.popcorn", qos: .userInitiated, target: nil)
                                queue.async {
                                    if let urlObject = URL(string: url), let downloadedData = try? Data(contentsOf: urlObject), let downloadedImage = UIImage(data: downloadedData) {
                                        let newFriend = Person(name: name, id: id, image: downloadedImage)
                                        self.friends.append(newFriend)
                                        self.friends.sort() { (first,second) in
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
