//
//  MoreTableViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class MoreTableViewController: UITableViewController {
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let mvc = tabBarController as? MoviesTabBarController {
            user = mvc.currentUser
            userTableViewCell.user = user
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var userTableViewCell: UserTableViewCell!

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            FBSDKLoginManager().logOut()
            if let mvc = tabBarController as? MoviesTabBarController {
                mvc.showLoginScreen(true)
            }
        }
    }
    
    

}
