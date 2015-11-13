//
//  MoviesTabBarController.swift
//  Movies
//
//  Created by Mathias Quintero on 11/12/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class MoviesTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    @IBAction func unwindToViewControllerNameHere(segue: UIStoryboardSegue) {
        currentUser = User()
        print(FBSDKAccessToken.currentAccessToken())
    }

    let dataFetcher = MovieDataFetcher()
    
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataFetcher.getDefaultsFromMemory()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if FBSDKAccessToken.currentAccessToken() == nil {
            performSegueWithIdentifier("login", sender: self)
        } else {
            currentUser = User()
        }
    }
}
