//
//  PersonViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 10/17/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import JFMinimalNotifications
import DoneHUD

protocol PersonBioDataSource {
    func currentPerson() -> Actor
    func picture() -> UIImage?
}

class PersonViewController: UITableViewController, MovieDetailDataSource, MovieReceiverProtocol {
    
    var likeButton: UIBarButtonItem?
    
    func likePerson(_ send: AnyObject?) {
        if delegate?.currentPerson().toggleActorInSubscriptions() ?? false {
            likeButton?.image = UIImage(named: "Like Filled-25")
            DoneHUD.showInView(self.view.superview ?? self.view, message: "Following " + (delegate?.currentPerson().name ?? ""))
        } else {
            likeButton?.image = UIImage(named: "heart-7")
        }
    }
    
    var loadingForFirstTime = true
    
    var cageNotification: JFMinimalNotification?
    
    func dismissNotification() {
        cageNotification?.dismiss()
    }
    
    var currentMovie: Movie?

    func imageDownloaded() {
        tableView.reloadData()
    }
    
    func moviesArrived(_ newMovies: [Movie]) {
        self.movies = newMovies
        for movie in newMovies {
            movie.subscribeToImage(self)
        }
        tableView.reloadData()
        
    }
    
    var delegate: PersonBioDataSource?
    
    var movies = [Movie]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return (movies.count ?? 0) + 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0: return headerCell()
        case 1: return descriptionCell()
        default:
            if indexPath.row == movies.count ?? 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "allmovies") ?? UITableViewCell()
                return cell
            } else {
                return movieCell(indexPath.row)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row != movies.count {
            currentMovie = movies[indexPath.row]
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func headerCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "person") as? HeadShotTableViewCell ?? HeadShotTableViewCell()
        cell.person = delegate?.currentPerson()
        return cell
    }
    
    func descriptionCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "description") as? DescriptionTableViewCell ?? DescriptionTableViewCell()
        cell.descriptionText = delegate?.currentPerson().bio
        return cell
    }
    
    func movieCell(_ movie: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movie") as? ClearMovieTableViewCell ?? ClearMovieTableViewCell()
        cell.movie = movies[movie]
        return cell
    }
    
    func currentMovieForDetail() -> Movie? {
        return currentMovie
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destiationViewController = segue.destination as? MovieDetailViewController {
            destiationViewController.movieDataSource = self
            currentMovie?.subscribeToImage(destiationViewController)
        }
        if let mvc = segue.destination as? AllMoviesFromActorTableViewController {
            mvc.delegate = self.delegate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        likeButton = UIBarButtonItem(image: UIImage(named: "heart-7"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(PersonViewController.likePerson(_:)))
        navigationItem.rightBarButtonItem = likeButton
        if let actorUnwrapped = delegate?.currentPerson() {
            if actorUnwrapped.isActorInSubscriptions() {
                likeButton?.image = UIImage(named: "Like Filled-25")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if movies.count == 0 {
            delegate?.currentPerson().fetchMovies(self, all: false)
        }
        title = delegate?.currentPerson().name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let actor = delegate?.currentPerson() {
            if actor.id == 2963 && loadingForFirstTime {
                cageNotification = JFMinimalNotification(style: JFMinimalNotificationStyle.success, title: "Congratulations!", subTitle: "You've reached Nic Cage!!!", dismissalDelay: 4.0)
                cageNotification = JFMinimalNotification(style: JFMinimalNotificationStyle.success, title: "Congratulations!", subTitle: "You've reached Nic Cage!!!", dismissalDelay: 4.0, touchHandler: self.dismissNotification)
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
