//
//  User.swift
//  Movies
//
//  Created by Mathias Quintero on 11/13/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
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
            print("Request Done!")
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
            if let url = ("https://moviesbackend.herokuapp.com/notifyWatch?userid=" + id + "&pref=" + (notifyWatchlist ? "1" : "0")).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
                Alamofire.request(.POST, url)
            }
        }
    }
    
    var notifyArtist = true {
        didSet {
            if let url = ("https://moviesbackend.herokuapp.com/notifySub?userid=" + id + "&pref=" + (notifyArtist ? "1" : "0")).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
                Alamofire.request(.POST, url)
            }
        }
    }
    
    var languagePreference: LanguagePreference {
        didSet {
            if let url = ("https://moviesbackend.herokuapp.com/language?userid=" + id + "&pref=" + languagePreference.rawValue).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
                Alamofire.request(.POST, url)
            }
        }
    }
    
    var distanceRange: Int {
        didSet {
            if let url = ("https://moviesbackend.herokuapp.com/distance?userid=" + id + "&pref=" + distanceRange.description).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
                Alamofire.request(.POST, url)
            }
        }
    }
    
    func getWatchList(handler: ([Int]) -> ()) {
        let url = "https://moviesbackend.herokuapp.com/watchlist?userid=" + id
        Alamofire.request(.GET, url).responseJSON() { (response) in
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
        if let url = ("https://moviesbackend.herokuapp.com/watchlist?userid=" + id + "&movie=" + movieID.description).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
            Alamofire.request(.POST, url)
        }
    }
    
    func removeFromWatchList(movieID: Int) {
        if let url = ("https://moviesbackend.herokuapp.com/watchlist?userid=" + id + "&movie=" + movieID.description + "&remove=1").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
            Alamofire.request(.POST, url)
        }
    }
    
    func getPreferences() {
        let url = "https://moviesbackend.herokuapp.com/user?userid=" + id
        Alamofire.request(.GET, url).responseJSON() { (response) in
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
    
}
