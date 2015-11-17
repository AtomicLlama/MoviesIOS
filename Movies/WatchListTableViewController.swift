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
        view.backgroundColor = UIColor(red:0.82, green:0.44, blue:0.39, alpha:1)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.backgroundColor = UIColor(red:0.82, green:0.44, blue:0.39, alpha:1)
        tableView.separatorColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        list?.getListOfMovies(self)
    }
    
    func imageDownloaded() {
        tableView.reloadData()
    }
    
    func moviesArrived(newMovies: [Movie]) {
        movies = newMovies
        let key = random() % min((list?.knownMovies.count ?? 0), 10)
        var i = 0;
        for tuple in list?.knownMovies ?? [String:Movie]() {
            if i == key {
                randomMovie = tuple.1
                break;
            }
            i++
        }
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return movies.isEmpty ? 2 : 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 || !movies.isEmpty {
            return max(movies.count, 1)
        } else {
            if movies.isEmpty {
                return 1
            }
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !movies.isEmpty
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let movie = movies[sourceIndexPath.row]
        movies.removeAtIndex(sourceIndexPath.row)
        movies.insert(movie, atIndex: destinationIndexPath.row)
        list?.reArrangeWatchList(sourceIndexPath.row, to: destinationIndexPath.row)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 || !movies.isEmpty {
            let cell = tableView.dequeueReusableCellWithIdentifier("movie") as? WatchListMovieCell ?? WatchListMovieCell()
            if movies.isEmpty {
                cell.movie = randomMovie
            } else {
                cell.movie = movies[indexPath.row]
                let handler = { () -> () in
                    if let path = self.tableView.indexPathForCell(cell) {
                        self.movies.removeAtIndex(path.row)
                        cell.movie?.toggleMovieInWatchList()
                        if !self.movies.isEmpty {
                            self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Top)
                        } else {
                            self.tableView.reloadData()
                        }
                        
                    }
                }
                cell.defaultColor = UIColor(red:0.82, green:0.44, blue:0.39, alpha:1)
                cell.setSwipeGestureWithView(UIView(), color: UIColor(red:0.82, green:0.44, blue:0.39, alpha:1), mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State1) { (void) in handler() }
                cell.setSwipeGestureWithView(UIView(), color: UIColor(red:0.82, green:0.44, blue:0.39, alpha:1), mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State2) { (void) in handler() }
                cell.setSwipeGestureWithView(UIView(), color: UIColor(red:0.82, green:0.44, blue:0.39, alpha:1), mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State3) { (void) in handler() }
                cell.setSwipeGestureWithView(UIView(), color: UIColor(red:0.82, green:0.44, blue:0.39, alpha:1), mode: MCSwipeTableViewCellMode.Exit, state: MCSwipeTableViewCellState.State4) { (void) in handler() }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("sugestionCell")!
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
        
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1 || !movies.isEmpty
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !movies.isEmpty {
            currentMovie = movies[indexPath.row]
        } else if movies.isEmpty && indexPath.section == 1 {
            currentMovie = randomMovie
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let mvc = segue.destinationViewController as? MovieDetailViewController {
            mvc.movieDataSource = self
        }
    }

}
