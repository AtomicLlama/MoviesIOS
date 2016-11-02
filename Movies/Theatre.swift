//
//  Theatre.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

class Theatre {
    let name: String
    var location: CLLocation
    
    init() {
        name = "Cinema München"
        location = CLLocation(latitude: 0.0, longitude: 0.0)
    }
    
    init(name: String, location: String) {
        self.name = name
        self.location = CLLocation(latitude: 0, longitude: 0)
        if let url = ("http://maps.google.com/maps/api/geocode/json?sensor=false&address=" + location).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
            Alamofire.request(url).responseJSON() { (response) in
                if let data = response.result.value as? [String:AnyObject], let results = data["results"] as? [AnyObject], let result = results.first as? [String:AnyObject], let geo = result["geometry"] as? [String:AnyObject], let loc = geo["location"] as? [String:AnyObject] {
                    if let lat = loc["lat"] as? Double, let lon = loc["lng"] as? Double {
                        self.location = CLLocation(latitude: lat, longitude: lon)
                    }
                }
            }
        }
    }
    
}
