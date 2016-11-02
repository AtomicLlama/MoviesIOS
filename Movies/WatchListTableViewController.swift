//
//  WatchListTableViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 10/20/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import MCSwipeTableViewCell

class WatchListTableViewController: UITableViewController, MovieReceiverProtocol, MovieDetailDataSource {
    
    
    var list: MovieDataFetcher?
    
    var randomMovie: Movie?
    
    var movies = [Movie]()
    
    var currentMovie: Movie?
    
    func currentMovieForDetail() -> Movie? {
        return currentMovie
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let mvc = tabBarController as? MoviesTabBarController {
            list = mvc.dataFetcher
        }
        view.backgroundColor = Constants.tintColor
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = Constants.tintColor
        tableView.separatorColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        list?.getListOfMovies(self)
    }
    
    func imageDownloaded() {
        tableView.reloadData()
    }
    
    func moviesArrived(_ newMovies: [Movie]) {
        movies = newMovies
        let key = Int(arc4random()) % min((list?.knownMovies.count ?? 0), 10)
        var i = 0;
        for tuple in list?.knownMovies ?? [String:Movie]() {
            if i == key {
                randomMovie = tuple.1
                break;
            }
            i += 1
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return movies.isEmpty ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 || !movies.isEmpty {
            return max(movies.count, 1)
        } else {
            if movies.isEmpty {
                return 1
            }
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !movies.isEmpty
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movie = movies[sourceIndexPath.row]
        movies.remove(at: sourceIndexPath.row)
        movies.insert(movie, at: destinationIndexPath.row)
        list?.reArrangeWatchList(sourceIndexPath.row, to: destinationIndexPath.row)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 || !movies.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "movie") as? WatchListMovieCell ?? WatchListMovieCell()
            if movies.isEmpty {
                cell.movie = randomMovie
            } else {
                cell.movie = movies[indexPath.row]
                let handler = { () -> () in
                    if let path = self.tableView.indexPath(for: cell) {
                        self.movies.remove(at: path.row)
                        cell.movie?.toggleMovieInWatchList()
                        if !self.movies.isEmpty {
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
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sugestionCell")!
            cell.backgroundColor = UIColor.clear
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 || !movies.isEmpty
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !movies.isEmpty {
            currentMovie = movies[indexPath.row]
        } else if movies.isEmpty && indexPath.section == 1 {
            currentMovie = randomMovie
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? MovieDetailViewController {
            mvc.movieDataSource = self
        }
    }

}
