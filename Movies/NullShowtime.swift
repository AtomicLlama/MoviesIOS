//
//  NullShowtime.swift
//  Movies
//
//  Created by Mathias Quintero on 12/31/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
class NullShowtime: Showtime {
    init(time: NSDate) {
        super.init(name: "", time: time, theatre: Theatre())
    }
}