//
//  ViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 10/15/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import PZPullToRefresh
import MCSwipeTableViewCell

class MovieListViewController: UITableViewController, MovieDetailDataSource, MovieReceiverProtocol, PZPullToRefreshDelegate {
    
    var refreshHeaderView: PZPullToRefreshView?
    
    var fetcher: MovieDataFetcher?
    
    var movies = [Movie]()
    
    var currentMovie = 0
    
    func moviesArrived(newMovies: [Movie]) {
        
        //Get the movie objects and refresh the view.
        
        movies = newMovies
        tableView.reloadData()
        if refreshHeaderView != nil {
            
            //Stop refreshing animation
            
            self.refreshHeaderView?.isLoading = false
            self.refreshHeaderView?.refreshScrollViewDataSourceDidFinishedLoading(self.tableView)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func imageDownloaded() {
        
        //Reload tables if the image has been downloaded.
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let mvc = tabBarController as? MoviesTabBarController {
            fetcher = mvc.dataFetcher
        }
        fetcher?.receiver = self
        
        //Set up basic UI
        tableView.separatorColor = UIColor.clearColor()
        tableView.backgroundColor = Constants.tintColor
        self.edgesForExtendedLayout = UIRectEdge.None
        if refreshHeaderView == nil {
            let view = PZPullToRefreshView(frame: CGRectMake(0, 0 - tableView.bounds.size.height, tableView.bounds.size.width, tableView.bounds.size.height))
            view.delegate = self
            self.tableView.addSubview(view)
            refreshHeaderView = view
            refreshHeaderView?.backgroundColor = Constants.tintColor
        }
        
        //Fetch Movies immediatly
        
        if movies.count == 0 {
            fetcher?.fetchNewMovies()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCellWithIdentifier("movie") as? MovieTableViewCell ?? MovieTableViewCell()
        dequeuedCell.movie = movies[indexPath.row]
        var writeSwipes = { () in return }
        let handler = { () -> () in
            dequeuedCell.movie?.toggleMovieInWatchList()
            writeSwipes()
        }
        writeSwipes = { () in
            var image: UIImage?
            var color = Constants.tintColor
            if dequeuedCell.movie?.isMovieInWatchList() ?? false {
                image = UIImage(named: "heart-7")
                color = UIColor.grayColor()
            } else {
                image = UIImage(named: "Like Filled-25")
            }
            dequeuedCell.firstTrigger = 0.3
            dequeuedCell.defaultColor = color
            dequeuedCell.setSwipeGestureWithView(self.viewWithImage(image), color: color, mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State1) { (void) in handler() }
            dequeuedCell.setSwipeGestureWithView(self.viewWithImage(image), color: color, mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State2) { (void) in handler() }
            dequeuedCell.setSwipeGestureWithView(self.viewWithImage(image), color: color, mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State3) { (void) in handler() }
            dequeuedCell.setSwipeGestureWithView(self.viewWithImage(image), color: color, mode: MCSwipeTableViewCellMode.Switch, state: MCSwipeTableViewCellState.State4) { (void) in handler() }
        }
        writeSwipes()
        return dequeuedCell
    }
    
    func viewWithImage(image: UIImage?) -> UIView {
        let imageView = UIImageView(image: image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        imageView.tintColor = UIColor.whiteColor()
        imageView.contentMode = UIViewContentMode.Center
        return imageView
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentMovie = indexPath.row
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? MovieDetailViewController {
            destinationViewController.movieDataSource = self
        } else if let destinationViewController = segue.destinationViewController as? SearchTableViewController {
            destinationViewController.delegate = fetcher
            destinationViewController.popFilm = movies
        }
    }
    
    func currentMovieForDetail() -> Movie? {
        return movies[currentMovie]
    }
    
    func pullToRefreshDidTrigger(view: PZPullToRefreshView) {
        refreshHeaderView?.isLoading = true
        fetcher?.fetchNewMovies()
    }
    
    func pullToRefreshLastUpdated(view: PZPullToRefreshView) -> NSDate {
        return NSDate()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshHeaderView?.refreshScrollViewDidScroll(scrollView)
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshHeaderView?.refreshScrollViewDidEndDragging(scrollView)
    }
    
    
}

