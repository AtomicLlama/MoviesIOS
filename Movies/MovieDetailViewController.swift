//
//  MovieDetailViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 10/15/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import YouTubePlayer

protocol MovieDetailDataSource {
    func currentMovieForDetail() -> Movie?
}

class MovieDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PersonBioDataSource, MovieReceiverProtocol, YouTubePlayerDelegate {
    
    //MARK: Data
    
    var likeButton: UIBarButtonItem?
    
    var movieDataSource: MovieDetailDataSource?
    
    var currentActor: Actor?
    
    func currentPerson() -> Actor {
        return currentActor ?? Actor(director: "hjh")
    }
    
    func picture() -> UIImage? {
        return movieDataSource?.currentMovieForDetail()?.poster
    }
    
    func likeMovie(send: AnyObject?) {
        if movieDataSource?.currentMovieForDetail()?.toggleMovieInWatchList() ?? false {
            likeButton?.image = UIImage(named: "Like Filled-25")
            DoneHUD.showInView(self.view, message: "Added To Watch List")
        } else {
            likeButton?.image = UIImage(named: "heart-7")
        }
        
    }
    
    func imageDownloaded() {
        tableView.reloadData()
        if backgroundImageView.image == nil {
            if let movieUnwrapped = movieDataSource?.currentMovieForDetail() {
                if let posterImage = movieUnwrapped.poster {
                    backgroundImageView.image = posterImage
                }
            }
        }
    }
    
    func moviesArrived(newMovies: [Movie]) {
        tableView.reloadData()
    }
    
    // MARK: Table View Stuff
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if movieDataSource?.currentMovieForDetail()?.trailerID != nil {
            return 6
        } else {
            return 5
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return min((movieDataSource?.currentMovieForDetail()?.actors.count) ?? 0, 5)
        }
        return 1
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section >= 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return titleRow()
        case 1: return descriptionRow()
        case 2: return directorRow()
        case 3: return actorRow(indexPath.row)
        case 4: return movieDataSource?.currentMovieForDetail()?.trailerID != nil ? trailerRow() : bookingRow()
        default: return bookingRow()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 3 {
            currentActor = movieDataSource?.currentMovieForDetail()?.actors[indexPath.row].0
        } else if indexPath.section == 2 {
            currentActor = movieDataSource?.currentMovieForDetail()?.director
        }
    }
    
    
    // MARK: Table View Cells by functionality
    
    func titleRow() -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("title") as? DetailViewTitleTableCell {
            cell.movie = movieDataSource?.currentMovieForDetail()
            return cell
        } else {
            let cell = DetailViewTitleTableCell()
            cell.movie = movieDataSource?.currentMovieForDetail()
            return cell
        }
    }
    
    func descriptionRow() -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("description") as? DescriptionTableViewCell {
            if let descriptionUnwrapped = movieDataSource?.currentMovieForDetail()?.description {
                cell.descriptionText = descriptionUnwrapped
            }
            return cell
        } else {
            let cell = DescriptionTableViewCell()
            if let descriptionUnwrapped = movieDataSource?.currentMovieForDetail()?.description {
                cell.descriptionText = descriptionUnwrapped
            }
            return cell
        }
    }
    
    func directorRow() -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("director") {
            cell.backgroundColor = UIColor.clearColor()
            if let director = movieDataSource?.currentMovieForDetail()?.director {
                cell.textLabel?.text = "Director: " + director.name
            }
            return cell
        } else {
            let cell = UITableViewCell()
            if let director = movieDataSource?.currentMovieForDetail()?.director {
                cell.textLabel?.text = "Director: " + director.name
            }
            return cell
        }
    }
    
    func actorRow(actor: Int) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("actor") as? ActorTableViewCell {
            cell.actor = movieDataSource?.currentMovieForDetail()?.actors[actor]
            return cell
        } else {
            let cell = ActorTableViewCell()
            cell.actor = movieDataSource?.currentMovieForDetail()?.actors[actor]
            return cell
        }
    }
    
    func bookingRow() -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("book") {
            cell.backgroundColor = UIColor.clearColor()
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func trailerRow() -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("trailer") as? TrailerViewCell ?? TrailerViewCell()
        if !cell.player.ready {
            cell.player.loadVideoID(movieDataSource?.currentMovieForDetail()?.trailerID ?? "")
        }
        cell.player.delegate = self
        return cell
    }
    
    
    // MARK: UI Misc. (Image, ...)
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            let effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.alpha = 0.8
            effectView.frame = (backgroundImageView.superview?.bounds)!
            backgroundImageView.addSubview(effectView)
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = UIColor.clearColor()
        }
    }
    
    // MARK: Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likeButton = UIBarButtonItem(image: UIImage(named: "heart-7"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("likeMovie:"))
        navigationItem.rightBarButtonItem = likeButton
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRectZero)
        if let movieUnwrapped = movieDataSource?.currentMovieForDetail() {
            self.title = movieUnwrapped.title
            if movieUnwrapped.isMovieInWatchList() {
                likeButton?.image = UIImage(named: "Like Filled-25")
            }
            movieUnwrapped.subscribeToImage(self)
            movieUnwrapped.getTrailerUrl(self)
            if let posterImage = movieUnwrapped.poster {
                backgroundImageView.image = posterImage
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let personDetailViewController = segue.destinationViewController as? PersonViewController {
            personDetailViewController.delegate = self
        }
    }
    
    func playerQualityChanged(videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        print(playbackQuality)
    }
    
    func playerReady(videoPlayer: YouTubePlayerView) {
        print("Player Ready")
    }
    
    func playerStateChanged(videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if videoPlayer.playerState == YouTubePlayerState.Paused || videoPlayer.playerState == YouTubePlayerState.Ended {
            self.view.setNeedsLayout()
            self.view.setNeedsUpdateConstraints()
            self.navigationController?.view.setNeedsUpdateConstraints()
            self.navigationController?.view.setNeedsLayout()
            // tableView.reloadData()
        }
    }
    
}
