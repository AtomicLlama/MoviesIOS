//
//  AllMoviesFromActorTableViewController.swift
//  
//
//  Created by Mathias Quintero on 5/14/16.
//
//

import UIKit

class AllMoviesFromActorTableViewController: UITableViewController, MovieDetailDataSource, MovieReceiverProtocol {

    var delegate: PersonBioDataSource?
    
    var currentMovie: Movie?
    
    func currentMovieForDetail() -> Movie? {
        return currentMovie
    }
    
    func actorsFetched() {
        tableView.reloadData()
    }
    
    func imageDownloaded() {
        tableView.reloadData()
    }
    
    func moviesArrived(_ newMovies: [Movie]) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.currentPerson().fetchMovies(self, all: true)
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        if let unwrappedActor = delegate?.currentPerson() {
            title = "Movies with: " + unwrappedActor.name
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
        return delegate?.currentPerson().movies?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "movie") as? ClearMovieTableViewCell {
            cell.movie = delegate?.currentPerson().movies?[indexPath.row]
            return cell
        } else {
            let cell = ClearMovieTableViewCell()
            cell.movie = delegate?.currentPerson().movies?[indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentMovie = delegate?.currentPerson().movies?[indexPath.row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destiationViewController = segue.destination as? MovieDetailViewController {
            destiationViewController.movieDataSource = self
            currentMovie?.subscribeToImage(destiationViewController)
        }
    }

}
