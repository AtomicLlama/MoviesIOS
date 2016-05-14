//
//  AllMoviesFromActorTableViewController.swift
//  
//
//  Created by Mathias Quintero on 5/14/16.
//
//

import UIKit

class AllMoviesFromActorTableViewController: UITableViewController, ActorFetchDataReceiver, MovieDetailDataSource {

    var delegate: PersonBioDataSource?
    
    var currentMovie: Movie?
    
    func currentMovieForDetail() -> Movie? {
        return currentMovie
    }
    
    func actorsFetched() {
        tableView.reloadData()
    }
    
    func receiveMoviesFromActor(movies: [Movie]?) {
        tableView.reloadData()
    }
    
    func receiverOfImage() -> MovieReceiverProtocol? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.currentPerson().fetchMovies(self, all: true)
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRectZero)
        if let unwrappedActor = delegate?.currentPerson() {
            title = "Movies with: " + unwrappedActor.name
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
        return delegate?.currentPerson().movies?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("movie") as? ClearMovieTableViewCell {
            cell.movie = delegate?.currentPerson().movies?[indexPath.row]
            return cell
        } else {
            let cell = ClearMovieTableViewCell()
            cell.movie = delegate?.currentPerson().movies?[indexPath.row]
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentMovie = delegate?.currentPerson().movies?[indexPath.row]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destiationViewController = segue.destinationViewController as? MovieDetailViewController {
            destiationViewController.movieDataSource = self
            currentMovie?.subscribeToImage(destiationViewController)
        }
    }

}
