//
//  FollowingTableViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 3/7/16.
//  Copyright © 2016 LS1 TUM. All rights reserved.
//

import UIKit
import MCSwipeTableViewCell

class FollowingTableViewController: UITableViewController,ActorReceiverProtocol, PersonBioDataSource {
    
    var currentActor: Actor?
    
    func currentPerson() -> Actor {
        return currentActor ?? Actor(director: "Nothing Selected")
    }
    
    func picture() -> UIImage? {
        return currentActor?.headshot
    }
    
    var subs = [Actor]()
    
    var delegate: MovieDataFetcher?
    
    func receiveActors(actors: [Actor]) {
        subs = actors
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = Constants.tintColor
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        if let mvc = tabBarController as? MoviesTabBarController {
            delegate = mvc.dataFetcher
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.getActorsFromSubscriptions(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, subs.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if subs.isEmpty {
            let cell = tableView.dequeueReusableCellWithIdentifier("not") ?? UITableViewCell()
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("actor") as? ActorFollowingTableViewCell ?? ActorFollowingTableViewCell()
        let actor = subs[indexPath.row]
        cell.actor = actor
        let handler = { () -> () in
            if let path = self.tableView.indexPathForCell(cell) {
                self.subs.removeAtIndex(path.row)
                cell.actor?.toggleActorInSubscriptions()
                if !self.subs.isEmpty {
                    self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Top)
                } else {
                    self.tableView.reloadData()
                }
            }
        }
        cell.defaultColor = Constants.tintColor
        cell.setSwipeGestureWithView(UIView(), color: Constants.tintColor, mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State1) { (void) in handler() }
        cell.setSwipeGestureWithView(UIView(), color: Constants.tintColor, mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State2) { (void) in handler() }
        cell.setSwipeGestureWithView(UIView(), color: Constants.tintColor, mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State3) { (void) in handler() }
        cell.setSwipeGestureWithView(UIView(), color: Constants.tintColor, mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State4) { (void) in handler() }
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if !subs.isEmpty {
            currentActor = subs[indexPath.row]
        }
        return indexPath
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let mvc = segue.destinationViewController as? PersonViewController {
            mvc.delegate = self
        }
    }

}
