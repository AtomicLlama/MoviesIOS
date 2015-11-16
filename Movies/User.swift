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

enum LanguagePreference: String {
    case OriginalLanguage = "Original Language"
    case Subtitled = "Subtitled"
    case Dubbed = "Dubbed"
    case SubOrOriginal = "Subtitled Or Original Language"
    case SubOrDub = "Subtitles or Original Language"
    case NotCare = "Don't care"
    
    func getPref(input: String) -> LanguagePreference {
        switch input {
        case OriginalLanguage.rawValue:
            return OriginalLanguage
        case Subtitled.rawValue:
            return Subtitled
        case Dubbed.rawValue:
            return Dubbed
        case SubOrOriginal.rawValue:
            return SubOrOriginal
        case SubOrDub.rawValue:
            return SubOrDub
        default:
            return NotCare
        }
    }
}

class User {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var name: String
    var image: UIImage?
    var id: String
    var languagePreference: LanguagePreference {
        didSet {
            defaults.setObject(languagePreference.rawValue, forKey: "languagePreference")
        }
    }
    
    var distanceRange: Int {
        didSet {
            defaults.setInteger(distanceRange, forKey: "distancePreference")
        }
    }
    
    private func getPref(input: String) -> LanguagePreference {
        switch input {
        case LanguagePreference.OriginalLanguage.rawValue:
            return LanguagePreference.OriginalLanguage
        case LanguagePreference.Subtitled.rawValue:
            return LanguagePreference.Subtitled
        case LanguagePreference.Dubbed.rawValue:
            return LanguagePreference.Dubbed
        case LanguagePreference.SubOrOriginal.rawValue:
            return LanguagePreference.SubOrOriginal
        case LanguagePreference.SubOrDub.rawValue:
            return LanguagePreference.SubOrDub
        default:
            return LanguagePreference.NotCare
        }
    }
    
    let token: String
    
    init(name: String, token: String, id: String) {
        self.name = name
        self.token = token
        self.id = id
        let pref = defaults.stringForKey("languagePreference") ?? ""
        let dist = defaults.integerForKey("distancePreference") ?? 10
        distanceRange = dist
        if dist == 0 {
            distanceRange = 10
        }
        languagePreference = LanguagePreference.NotCare
        languagePreference = getPref(pref)
        getProfilePic()
    }
    
    init() {
        name = ""
        token = FBSDKAccessToken.currentAccessToken().tokenString ?? ""
        id = ""
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields:":"name,id"])
        let pref = defaults.stringForKey("languagePreference") ?? ""
        let dist = defaults.integerForKey("distancePreference") ?? 10
        distanceRange = dist
        if dist == 0 {
            distanceRange = 10
        }
        languagePreference = LanguagePreference.NotCare
        languagePreference = getPref(pref)
        request.startWithCompletionHandler() { (_,result,_) -> Void in
            print("Request Done!")
            if let dictionary = result as? NSDictionary, username = dictionary["name"] as? String {
                self.name = username
                self.getProfilePic()
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
