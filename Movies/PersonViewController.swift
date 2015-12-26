//
//  PersonViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 10/17/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import JFMinimalNotifications

protocol PersonBioDataSource {
    func currentPerson() -> Actor
    func picture() -> UIImage?
}

class PersonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MovieDetailDataSource, ActorFetchDataReceiver, MovieReceiverProtocol {
    
    var loadingForFirstTime = true
    
    var cageNotification: JFMinimalNotification?
    
    func dismissNotification() {
        cageNotification?.dismiss()
    }
    
    var currentMovie: Movie?

    func imageDownloaded() {
        tableView.reloadData()
    }
    
    func receiverOfImage() -> MovieReceiverProtocol? {
        return self
    }
    
    func movieAlreadyReceived(id: String) -> Bool {
        for movie in movies {
            if movie?.id == id{
                return  true
            }
        }
        return false
    }
    
    func moviesArrived(newMovies: [Movie]) {
        self.movies = newMovies
        tableView.reloadData()
    }
    
    @IBOutlet weak var backgroundMovieView: UIImageView!
    
    weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = UIColor.clearColor()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.estimatedRowHeight = tableView.rowHeight
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }
    
    var delegate: PersonBioDataSource?
    
    func receiveMoviesFromActor(movies: Movie) {
        if !movieAlreadyReceived(movies.id) {
            self.movies.append(movies)
        }
        tableView.reloadData()
    }
    
    
    var movies = [Movie?]()
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return movies.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0: return headerCell()
        case 1: return descriptionCell()
        default: return movieCell(indexPath.row)
        }
        
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 2
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            currentMovie = movies[indexPath.row]
        }
    }
    
    func headerCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("person") as? HeadShotTableViewCell ?? HeadShotTableViewCell()
        cell.person = delegate?.currentPerson()
        return cell
    }
    
    func descriptionCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("description") as? DescriptionTableViewCell ?? DescriptionTableViewCell()
        cell.descriptionText = delegate?.currentPerson().bio
        return cell
    }
    
    func movieCell(movie: Int) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("movie") as? ClearMovieTableViewCell ?? ClearMovieTableViewCell()
        cell.movie = movies[movie]
        return cell
    }
    
    func currentMovieForDetail() -> Movie? {
        return currentMovie
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destiationViewController = segue.destinationViewController as? MovieDetailViewController {
            destiationViewController.movieDataSource = self
            currentMovie?.subscribeToImage(destiationViewController)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundMovieView.clipsToBounds = true
        let effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.alpha = 0.8
        //effectView.frame = (backgroundMovieView.superview?.bounds)!
        effectView.frame = CGRectMake(backgroundMovieView.frame.origin.x, backgroundMovieView.frame.origin.y, backgroundMovieView.frame.width + 40, backgroundMovieView.frame.height + 100)
        backgroundMovieView.addSubview(effectView)
        if let moviePoster = delegate?.picture() {
            backgroundMovieView.image = moviePoster
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        if movies.count == 0 {
            delegate?.currentPerson().fetchMovies(self)
        }
        title = delegate?.currentPerson().name
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let actor = delegate?.currentPerson() {
            if actor.id == "2963" && loadingForFirstTime {
                cageNotification = JFMinimalNotification(style: JFMinimalNotificationStyle.Success, title: "Congratulations!", subTitle: "You've reached Nic Cage!!!", dismissalDelay: 4.0)
                cageNotification = JFMinimalNotification(style: JFMinimalNotificationStyle.Success, title: "Congratulations!", subTitle: "You've reached Nic Cage!!!", dismissalDelay: 4.0, touchHandler: self.dismissNotification)
                cageNotification?.presentFromTop = true
                cageNotification?.edgePadding = UIEdgeInsetsMake(60, 0, 0, 0)
                cageNotification?.backgroundColor = Constants.tintColor
                let cage = UIImageView(image: UIImage(named: "cage"))
                cage.layer.masksToBounds = true
                cageNotification?.setLeftAccessoryView(cage, animated: true)
                view.superview?.addSubview(cageNotification!)
                cageNotification?.show()
                loadingForFirstTime = false
            }
        }
    }
    
}
