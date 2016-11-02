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
    
    @IBAction func unwindToViewControllerNameHere(_ segue: UIStoryboardSegue) {

    }

    let dataFetcher = MovieDataFetcher()
    
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FBSDKAccessToken.current() != nil {
            currentUser = User(fetcher: dataFetcher)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func showLoginScreen() {
        performSegue(withIdentifier: "loginAnimated", sender: self)
    }
}
