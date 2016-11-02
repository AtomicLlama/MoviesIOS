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
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        if let unwrappedMovie = delegate?.currentMovieForDetail() {
            title = "Cast of: " + unwrappedMovie.title
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.currentMovieForDetail()?.actors.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "actor") as? ActorTableViewCell {
            cell.actor = delegate?.currentMovieForDetail()?.actors[indexPath.row]
            return cell
        } else {
            let cell = ActorTableViewCell()
            cell.actor = delegate?.currentMovieForDetail()?.actors[indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentActor = delegate?.currentMovieForDetail()?.actors[indexPath.row].0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? PersonViewController {
            mvc.delegate = self
        }
    }
    
    

}
