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

class User {
    
    var name: String
    var image: UIImage?
    var id: String
    let token: String
    
    init(name: String, token: String, id: String) {
        self.name = name
        self.token = token
        self.id = id
        getProfilePic()
    }
    
    init() {
        name = ""
        token = FBSDKAccessToken.currentAccessToken().tokenString ?? ""
        id = ""
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields:":"name,id"])
        request.startWithCompletionHandler() { (_,result,_) -> Void in
            print("Request Done!")
            if let dictionary = result as? NSDictionary, username = dictionary["name"] as? String {
                self.name = username
                self.getProfilePic()
            }
        }
    }
    
    func getProfilePic() {
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name,picture"])
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
