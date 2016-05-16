//
//  ViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 10/15/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import PZPullToRefresh
import SFFocusViewLayout

class MovieListViewController: UICollectionViewController, MovieDetailDataSource, MovieReceiverProtocol, PZPullToRefreshDelegate {
    
    var refreshHeaderView: PZPullToRefreshView?
    
    var fetcher: MovieDataFetcher?
    
    var movies = [Movie]()
    
    var currentMovie = 0
    
    func moviesArrived(newMovies: [Movie]) {
        
        for movie in newMovies {
            movie.fetchDetailImage(self)
        }
        
        //Get the movie objects and refresh the view.
        
        movies = newMovies
        collectionView!.reloadData()
        if refreshHeaderView != nil {
            
            //Stop refreshing animation
            
            self.refreshHeaderView?.isLoading = false
            self.refreshHeaderView?.refreshScrollViewDataSourceDidFinishedLoading(self.collectionView!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView!.reloadData()
    }
    
    func imageDownloaded() {
        collectionView!.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let mvc = tabBarController as? MoviesTabBarController {
            fetcher = mvc.dataFetcher
        }
        fetcher?.receiver = self
        
        //Set up basic UI
        collectionView!.backgroundColor = Constants.tintColor
        self.edgesForExtendedLayout = UIRectEdge.None
        if refreshHeaderView == nil {
            let view = PZPullToRefreshView(frame: CGRectMake(0, 0 - collectionView!.bounds.size.height, collectionView!.bounds.size.width, collectionView!.bounds.size.height))
            view.delegate = self
            self.collectionView!.addSubview(view)
            refreshHeaderView = view
            refreshHeaderView?.backgroundColor = Constants.tintColor
        }
        
        
        collectionView!.register(CollectionViewCell)
        
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView!.backgroundColor = UIColor(red: 51/255, green: 55/255, blue: 61/255, alpha: 1)
        
        //Fetch Movies immediatly
        
        if movies.count == 0 {
            fetcher?.fetchNewMovies()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as CollectionViewCell
        dequeuedCell.movie = movies[indexPath.row]
        return dequeuedCell
    }
    
    func viewWithImage(image: UIImage?) -> UIView {
        let imageView = UIImageView(image: image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        imageView.tintColor = UIColor.whiteColor()
        imageView.contentMode = UIViewContentMode.Center
        return imageView
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        currentMovie = indexPath.row
        performSegueWithIdentifier("showMovie", sender: self)
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

