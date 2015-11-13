//
//  MoviesTabBarController.swift
//  Movies
//
//  Created by Mathias Quintero on 11/12/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class MoviesTabBarController: UITabBarController, UITabBarControllerDelegate {

    let dataFetcher = MovieDataFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataFetcher.getDefaultsFromMemory()
    }
    
}
