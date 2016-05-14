//
//  AllCastTableViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 5/14/16.
//  Copyright © 2016 LS1 TUM. All rights reserved.
//

import UIKit

class AllCastTableViewController: UITableViewController, MovieActorsReceiver, PersonBioDataSource {
    
    var delegate: MovieDetailDataSource?
    
    var currentActor: Actor?
    
    func actorsFetched() {
        tableView.reloadData()
    }
    
    func currentPerson() -> Actor {
        return currentActor ?? Actor(director: "No Name Available")
    }
    
    func picture() -> UIImage? {
        return delegate?.currentMovieForDetail()?.poster
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.currentMovieForDetail()?.fetchActors(self, all: true)
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRectZero)
        if let unwrappedMovie = delegate?.currentMovieForDetail() {
            title = "Cast of: " + unwrappedMovie.title
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.currentMovieForDetail()?.actors.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("actor") as? ActorTableViewCell {
            cell.actor = delegate?.currentMovieForDetail()?.actors[indexPath.row]
            return cell
        } else {
            let cell = ActorTableViewCell()
            cell.actor = delegate?.currentMovieForDetail()?.actors[indexPath.row]
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentActor = delegate?.currentMovieForDetail()?.actors[indexPath.row].0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let mvc = segue.destinationViewController as? PersonViewController {
            mvc.delegate = self
        }
    }
    
    

}
