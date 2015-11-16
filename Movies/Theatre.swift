//
//  Theatre.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
import CoreLocation

class Theatre {
    let name: String
    let location: CLLocation
    let website: String
    
    init() {
        name = "Cinema München"
        location = CLLocation(latitude: 0.0, longitude: 0.0)
        website = "http://google.com"
    }
    
}