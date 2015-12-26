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

    }

    let dataFetcher = MovieDataFetcher()
    
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FBSDKAccessToken.currentAccessToken() != nil {
            currentUser = User(fetcher: dataFetcher)
            dataFetcher.getter = currentUser
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func showLoginScreen() {
        performSegueWithIdentifier("loginAnimated", sender: self)
    }
}
