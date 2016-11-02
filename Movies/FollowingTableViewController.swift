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
    
    func receiveActors(_ actors: [Actor]) {
        subs = actors
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = Constants.tintColor
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        if let mvc = tabBarController as? MoviesTabBarController {
            delegate = mvc.dataFetcher
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.getActorsFromSubscriptions(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, subs.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if subs.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "not") ?? UITableViewCell()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "actor") as? ActorFollowingTableViewCell ?? ActorFollowingTableViewCell()
        let actor = subs[indexPath.row]
        cell.actor = actor
        let handler = { () -> () in
            if let path = self.tableView.indexPath(for: cell) {
                self.subs.remove(at: path.row)
                cell.actor?.toggleActorInSubscriptions()
                if !self.subs.isEmpty {
                    self.tableView.deleteRows(at: [path], with: UITableViewRowAnimation.top)
                } else {
                    self.tableView.reloadData()
                }
            }
        }
        cell.defaultColor = Constants.tintColor
        cell.setSwipeGestureWith(UIView(), color: Constants.tintColor, mode: MCSwipeTableViewCellMode.exit, state: MCSwipeTableViewCellState.state1) { (void) in handler() }
        cell.setSwipeGestureWith(UIView(), color: Constants.tintColor, mode: MCSwipeTableViewCellMode.exit, state: MCSwipeTableViewCellState.state2) { (void) in handler() }
        cell.setSwipeGestureWith(UIView(), color: Constants.tintColor, mode: MCSwipeTableViewCellMode.exit, state: MCSwipeTableViewCellState.state3) { (void) in handler() }
        cell.setSwipeGestureWith(UIView(), color: Constants.tintColor, mode: MCSwipeTableViewCellMode.exit, state: MCSwipeTableViewCellState.state4) { (void) in handler() }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if !subs.isEmpty {
            currentActor = subs[indexPath.row]
        }
        return indexPath
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? PersonViewController {
            mvc.delegate = self
        }
    }

}
