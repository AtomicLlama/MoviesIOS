//
//  WatchlistGetter.swift
//  Movies
//
//  Created by Mathias Quintero on 12/31/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
protocol WatchListGetter {
    func getWatchList(_ handler: @escaping ([Int]) -> ())
    func addToWatchList(_ movieID: Int)
    func removeFromWatchList(_ movieID: Int)
    func getSubscriptions(_ handler: @escaping ([Int]) -> ())
    func addSubscription(_ movieID: Int)
    func removeSubscription(_ movieID: Int)
}
