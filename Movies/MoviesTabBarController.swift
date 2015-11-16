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
        
        print(FBSDKAccessToken.currentAccessToken())
    }

    let dataFetcher = MovieDataFetcher()
    
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataFetcher.getDefaultsFromMemory()
        if FBSDKAccessToken.currentAccessToken() != nil {
            currentUser = User()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func showLoginScreen() {
        performSegueWithIdentifier("loginAnimated", sender: self)
    }
}
