//
//  WatchlistGetter.swift
//  Movies
//
//  Created by Mathias Quintero on 12/31/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
protocol WatchListGetter {
    func getWatchList(handler: ([Int]) -> ())
    func addToWatchList(movieID: Int)
    func removeFromWatchList(movieID: Int)
    func getSubscriptions(handler: ([Int]) -> ())
    func addSubscription(movieID: Int)
    func removeSubscription(movieID: Int)
}