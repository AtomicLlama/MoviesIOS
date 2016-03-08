//
//  MoreTableViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class MoreTableViewController: UITableViewController, ActorReceiverProtocol {
    
    var user: User? {
        didSet {
            loadSettings()
        }
    }
    
    func receiveActors(actors: [Actor]) {
        if actors.count == 1 {
            followingLabel.text = "1 Person"
        } else {
            followingLabel.text = actors.count.description + " People"
        }
    }
    
    @IBOutlet weak var followingLabel: UILabel!
    
    func loadSettings() {
        if let mvc = tabBarController as? MoviesTabBarController {
            mvc.dataFetcher.getActorsFromSubscriptions(self)
        }
        if let preference = user?.languagePreference.rawValue {
            languageCell.detailTextLabel?.text = preference
        }
        if let distance = user?.distanceRange {
            distanceCell.detailTextLabel?.text = distance.description + " km"
        }
        if let watchlistToggle = user?.notifyWatchlist {
            watchlistSwitch.setOn(watchlistToggle, animated: false)
            watchlistSwitch.addTarget(self, action: Selector("updateUserOnBool"), forControlEvents: UIControlEvents.ValueChanged)
        }
        if let artistToggle = user?.notifyArtist {
            artistSwitch.setOn(artistToggle, animated: false)
            artistSwitch.addTarget(self, action: Selector("updateUserOnBool"), forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    func updateUserOnBool() {
        user?.notifyArtist = artistSwitch.on
        user?.notifyWatchlist = watchlistSwitch.on
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let mvc = tabBarController as? MoviesTabBarController {
            user = mvc.currentUser
            userTableViewCell.user = user
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadSettings()
    }
    
    @IBOutlet weak var distanceCell: UITableViewCell!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var userTableViewCell: UserTableViewCell!

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 4 {
            FBSDKLoginManager().logOut()
            if let mvc = tabBarController as? MoviesTabBarController {
                mvc.showLoginScreen()
            }
        }
    }
    
    let watchlistSwitch = UISwitch()
    
    let artistSwitch = UISwitch()
    
    @IBOutlet weak var watchListNotCell: UITableViewCell! {
        didSet {
            watchListNotCell.accessoryView = watchlistSwitch
        }
    }
    @IBOutlet weak var artistCell: UITableViewCell! {
        didSet {
            artistCell.accessoryView = artistSwitch
        }
    }
    
    @IBOutlet weak var languageCell: UITableViewCell!
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == 4 {
            if let footer = view as? UITableViewHeaderFooterView, label = footer.textLabel {
                label.textAlignment = .Center
                footer.setNeedsDisplay()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let languageController = segue.destinationViewController as? LanguagePreferenceSelector {
            languageController.user = user
        } else if let distanceController = segue.destinationViewController as? DistancePreferenceSelector {
            distanceController.user = user
        }
    }

}
