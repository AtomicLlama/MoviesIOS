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
    let token: String
    
    init(name: String, token: String) {
        self.name = name
        self.token = token
        getProfilePic()
    }
    
    init() {
        name = ""
        token = FBSDKAccessToken.currentAccessToken().tokenString ?? ""
        let request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        request.startWithCompletionHandler() { (_,result,_) -> Void in
            print("Request Done!")
            if let dictionary = result as? NSDictionary, username = dictionary["name"] as? String {
                self.name = username
                self.getProfilePic()
            }
        }
    }
    
    func getProfilePic() {
        let request = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["fields":"url"])
        request.startWithCompletionHandler() { (_,result,error) -> Void in
            if error == nil {
                if let dictionary = result as? NSDictionary, url = dictionary["url"] as? String {
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
