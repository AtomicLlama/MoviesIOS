//
//  MovieReceiverProtocol.swift
//  Movies
//
//  Created by Mathias Quintero on 12/31/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
protocol MovieReceiverProtocol {
    func moviesArrived(newMovies: [Movie])
    func imageDownloaded()
}