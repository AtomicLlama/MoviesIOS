//
//  MovieDetailViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 10/15/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import YouTubePlayer
import MXParallaxHeader
import DoneHUD

protocol MovieDetailDataSource {
    func currentMovieForDetail() -> Movie?
}

class MovieDetailViewController: UITableViewController, PersonBioDataSource, MovieReceiverProtocol, MovieActorsReceiver, YouTubePlayerDelegate {
    
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
    
    func likeMovie(_ send: AnyObject?) {
        if movieDataSource?.currentMovieForDetail()?.toggleMovieInWatchList() ?? false {
            likeButton?.image = UIImage(named: "Like Filled-25")
            DoneHUD.showInView(self.view.superview ?? self.view, message: "Added To Watch List")
        } else {
            likeButton?.image = UIImage(named: "heart-7")
        }
    }
    
    func imageDownloaded() {
        if let movieUnwrapped = movieDataSource?.currentMovieForDetail() {
            if tableView.parallaxHeader.view === nil {
                if let detailImage = movieUnwrapped.detailImage {
                    let imageView = UIImageView(image: detailImage)
                    imageView.contentMode = UIViewContentMode.scaleAspectFill
                    tableView.parallaxHeader.view = imageView
                    tableView.parallaxHeader.height = 250
                    tableView.parallaxHeader.mode = MXParallaxHeaderMode.fill
                }
            }
        }
        tableView.reloadData()
    }
    
    func actorsFetched() {
        tableView.reloadData()
    }
    
    func moviesArrived(_ newMovies: [Movie]) {
        tableView.reloadData()
    }
    
    // MARK: Table View Stuff
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if movieDataSource?.currentMovieForDetail()?.trailerID != nil {
            return 6
        } else {
            return 5
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return min((movieDataSource?.currentMovieForDetail()?.actors.count) ?? 0, 5) + 1
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section >= 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return titleRow()
        case 1: return descriptionRow()
        case 2: return directorRow()
        case 3:
            if (indexPath.row == min((movieDataSource?.currentMovieForDetail()?.actors.count) ?? 0, 5)) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "allcast") ?? UITableViewCell()
                return cell
            }
            return actorRow(indexPath.row)
        case 4: return movieDataSource?.currentMovieForDetail()?.trailerID != nil ? trailerRow() : bookingRow()
        default: return bookingRow()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 &&
            indexPath.row != min((movieDataSource?.currentMovieForDetail()?.actors.count) ?? 0, 5) {
            currentActor = movieDataSource?.currentMovieForDetail()?.actors[indexPath.row].0
        } else if indexPath.section == 2 {
            currentActor = movieDataSource?.currentMovieForDetail()?.director
        }
    }
    
    func titleRow() -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "title") as? DetailViewTitleTableCell {
            cell.movie = movieDataSource?.currentMovieForDetail()
            return cell
        } else {
            let cell = DetailViewTitleTableCell()
            cell.movie = movieDataSource?.currentMovieForDetail()
            return cell
        }
    }
    
    func descriptionRow() -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "description") as? DescriptionTableViewCell {
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "director") {
            cell.backgroundColor = UIColor.clear
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
    
    func actorRow(_ actor: Int) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "actor") as? ActorTableViewCell {
            cell.actor = movieDataSource?.currentMovieForDetail()?.actors[actor]
            return cell
        } else {
            let cell = ActorTableViewCell()
            cell.actor = movieDataSource?.currentMovieForDetail()?.actors[actor]
            return cell
        }
    }
    
    func bookingRow() -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "book") {
            cell.backgroundColor = UIColor.clear
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func trailerRow() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trailer") as? TrailerViewCell ?? TrailerViewCell()
        if !cell.player.ready {
            cell.player.loadVideoID(movieDataSource?.currentMovieForDetail()?.trailerID ?? "")
        }
        cell.player.delegate = self
        return cell
    }
    
    // MARK: Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likeButton = UIBarButtonItem(image: UIImage(named: "heart-7"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MovieDetailViewController.likeMovie(_:)))
        navigationItem.rightBarButtonItem = likeButton
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        if let movieUnwrapped = movieDataSource?.currentMovieForDetail() {
            self.title = movieUnwrapped.title
            if movieUnwrapped.isMovieInWatchList() {
                likeButton?.image = UIImage(named: "Like Filled-25")
            }
            movieUnwrapped.subscribeToImage(self)
            movieUnwrapped.getTrailerUrl(self)
            if let detailImage = movieUnwrapped.detailImage {
                let imageView = UIImageView(image: detailImage)
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                tableView.parallaxHeader.view = imageView
                tableView.parallaxHeader.height = 250
                tableView.parallaxHeader.mode = MXParallaxHeaderMode.fill
                tableView.parallaxHeader.minimumHeight = 0
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        movieDataSource?.currentMovieForDetail()?.fetchDetailImage(self)
        movieDataSource?.currentMovieForDetail()?.fetchActors(self, all: false)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let personDetailViewController = segue.destination as? PersonViewController {
            personDetailViewController.delegate = self
        }
        if let mvc = segue.destination as? MovieTimesDetailTableViewController {
            mvc.movie = movieDataSource?.currentMovieForDetail()
        }
        if let mvc = segue.destination as? AllCastTableViewController {
            mvc.delegate = movieDataSource
        }
        if let mvc = segue.destination as? StreamingTableViewController {
            mvc.delegate = movieDataSource
        }
    }
    
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        // print(playbackQuality)
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        // print("Player Ready")
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
//        if playerState == YouTubePlayerState.Playing {
//            viewWillDisappear(true)
//            viewDidDisappear(true)
//        }
//        if videoPlayer.playerState == YouTubePlayerState.Paused || videoPlayer.playerState == YouTubePlayerState.Ended {
//            viewWillAppear(true)
//            viewDidAppear(true)
//            viewDidLoad()
//        }
    }
    
}
