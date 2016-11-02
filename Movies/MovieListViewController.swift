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
    
    func moviesArrived(_ newMovies: [Movie]) {
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    
    func imageDownloaded() {
        collectionView?.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let mvc = tabBarController as? MoviesTabBarController {
            fetcher = mvc.dataFetcher
        }
        fetcher?.receiver = self
        
        //Set up basic UI
        collectionView!.backgroundColor = Constants.tintColor
        self.edgesForExtendedLayout = UIRectEdge()
        if refreshHeaderView == nil {
            let view = PZPullToRefreshView(frame: CGRect(x: 0, y: 0 - collectionView!.bounds.size.height, width: collectionView!.bounds.size.width, height: collectionView!.bounds.size.height))
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as CollectionViewCell
        dequeuedCell.movie = movies[indexPath.row]
        return dequeuedCell
    }
    
    func viewWithImage(_ image: UIImage?) -> UIView {
        let imageView = UIImageView(image: image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        imageView.tintColor = UIColor.white
        imageView.contentMode = UIViewContentMode.center
        return imageView
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentMovie = indexPath.row
        performSegue(withIdentifier: "showMovie", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? MovieDetailViewController {
            destinationViewController.movieDataSource = self
        } else if let destinationViewController = segue.destination as? SearchTableViewController {
            destinationViewController.delegate = fetcher
            destinationViewController.popFilm = movies
        }
    }
    
    func currentMovieForDetail() -> Movie? {
        return movies[currentMovie]
    }
    
    func pullToRefreshDidTrigger(_ view: PZPullToRefreshView) {
        refreshHeaderView?.isLoading = true
        fetcher?.fetchNewMovies()
    }
    
    func pullToRefreshLastUpdated(_ view: PZPullToRefreshView) -> Date {
        return Date()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshHeaderView?.refreshScrollViewDidScroll(scrollView)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshHeaderView?.refreshScrollViewDidEndDragging(scrollView)
    }
    
    
}

