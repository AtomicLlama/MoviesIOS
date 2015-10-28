//
//  SearchTableViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 10/18/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import Alamofire

class SearchTableViewController: UITableViewController, UITextFieldDelegate, MovieReceiverProtocol, MovieDetailDataSource, PersonBioDataSource {
    
    var delegate: MovieInfoDataSource?
    
    var currentMovie: Movie?
    
    var currentActor: Actor?
    
    let activity = UIActivityIndicatorView()
    
    var popFilm: [Movie]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    func currentMovieForDetail() -> Movie? {
        return currentMovie
    }
    
    func currentPerson() -> Actor {
        return currentActor ?? Actor(director: "Quentin Tarantino")
    }
    
    func picture() -> UIImage? {
        return currentActor?.headshot
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.becomeFirstResponder()
        searchTextField.delegate = self
        searchTextField.leftView?.addSubview(activity)
        tableView.rowHeight = (CGFloat) (140)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.backgroundColor = UIColor(red:0.82, green:0.44, blue:0.39, alpha:1)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        title = "Search"
        
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    var results = [String:[AnyObject]]()
    
    var elements = [AnyObject]()
    
    func parseData(searchString: String?) {
        if let searchQuery =  searchString?.stringByReplacingOccurrencesOfString(" ", withString: "+") {
            let url = "http://api.themoviedb.org/3/search/multi?api_key=18ec732ece653360e23d5835670c47a0&query=" + searchQuery
            activity.startAnimating()
            Alamofire.request(.GET, url).responseJSON() { (response) in
                var refresh = self.elements.count != 0
                self.elements = []
                if let body = response.result.value as? [String:AnyObject], results = body["results"] as? [AnyObject] {
                    if results.count != 0 {
                        for i in 0...min(results.count-1,9) {
                            if let parsedItem = results[i] as? [String:AnyObject], medium = parsedItem["media_type"] as? String {
                                if medium == "movie" {
                                    let movieAsDictionary = parsedItem
                                    if let id = movieAsDictionary["id"] as? Int, title = movieAsDictionary["title"] as? String, plot = movieAsDictionary["overview"] as? String, year = movieAsDictionary["release_date"] as? String, rating = movieAsDictionary["vote_average"] as? Double, poster = movieAsDictionary["poster_path"] as? String {
                                        if let alreadyKnownMovie = self.delegate?.knownMovie(id.description) {
                                            self.elements.append(alreadyKnownMovie)
                                            self.tableView.reloadData()
                                        } else {
                                            let yearOnly: [String]
                                            if year == "" {
                                                yearOnly = [1970.description]
                                            } else {
                                                yearOnly = year.componentsSeparatedByString("-")
                                            }
                                            let newMovie = Movie(title: title, year: Int(yearOnly[0])!, rating: rating, description: plot, id: id.description, posterURL: "https://image.tmdb.org/t/p/w500" + poster, handler: self, dataSource: self.delegate)
                                            self.delegate?.learnMovie(id.description, movie: newMovie)
                                            self.elements.append(newMovie)
                                            self.tableView.reloadData()
                                        }
                                    }
                                } else if medium == "person" {
                                    if let actorID = parsedItem["id"] as? Int, name = parsedItem["name"] as? String {
                                        if let knownPerson = self.delegate?.knownPerson(actorID.description) {
                                            self.elements.append(knownPerson)
                                            if i == min(results.count-1,5) {
                                                self.results[searchString!] = self.elements
                                            }
                                        } else {
                                            let actorAsObject: Actor
                                            if let pic = parsedItem["profile_path"] as? String {
                                                actorAsObject = Actor(name: name, pic: "https://image.tmdb.org/t/p/w185" + pic, id: actorID.description, delegate: self.delegate)
                                            } else {
                                                actorAsObject = Actor(name: name, pic: nil, id: actorID.description, delegate: self.delegate)
                                            }
                                            self.elements.append(actorAsObject)
                                            self.delegate?.learnPerson(actorID.description, actor: actorAsObject)
                                        }
                                    }
                                }
                                if i == min(results.count-1,5) {
                                    self.results[searchString!] = self.elements
                                }
                            }
                        }
                    }
                    self.tableView.reloadData()
                    refresh = false
                } else {
                    print("Error Unwrapping Results m" + (response.result.value?.description ?? "Nothing!"))
                    if let body = response.result.value as? [String:AnyObject], status = body["status_code"] as? Int {
                        if status == 25 && searchString == self.searchTextField.text {
                            refresh = false
                            self.parseData(searchString)
                        }
                    }
                }
                if refresh {
                    self.tableView.reloadData()
                }
                self.activity.stopAnimating()
            }
        }
    }
    
    func imageDownloaded() {
        tableView.reloadData()
    }
    
    func moviesArrived(newMovies: [Movie]) {
        return
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string != " " {
            let replaced = NSString(string: textField.text ?? "").stringByReplacingCharactersInRange(range, withString: string)
            if  replaced != "" {
                if let prevResult = results[replaced] {
                    elements = prevResult
                    tableView.reloadData()
                } else {
                    parseData(replaced)
                }
                
            } else {
                elements = []
                tableView.reloadData()
            }
        }
        return true
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if elements.count == 0 {
            tableView.separatorColor = UIColor.clearColor()
        } else {
            tableView.separatorColor = UIColor.whiteColor()
        }
        return max(elements.count, 1)
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if elements.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("welcome") ?? UITableViewCell()
            cell.textLabel?.numberOfLines = 0
            var text = "I'm here to help.\nJust Type Away!\nWhat Are you waiting for?"
            if let movieTitle = popFilm?[(Int) (random()) % (popFilm?.count ?? 0)].titel {
                if (Int) (random())%2 == 0 {
                    text = "Search for \"" + movieTitle + "\", maybe...\nI've heard it's good."
                }
            }
            cell.textLabel?.text = text
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            return cell
        } else {
            if let actor = elements[indexPath.row] as? Actor {
                let cell = tableView.dequeueReusableCellWithIdentifier("actor") as? ActorTableViewCell ?? ActorTableViewCell()
                cell.actor = (actor, actor.bio)
                return cell
            } else if let movie = elements[indexPath.row] as? Movie {
                let cell = tableView.dequeueReusableCellWithIdentifier("movie") as? ClearMovieTableViewCell ?? ClearMovieTableViewCell()
                cell.movie = movie
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchTextField.resignFirstResponder()
        if elements.count > 0 {
            if let movie = elements[indexPath.row] as? Movie {
                currentMovie = movie
            } else if let actor = elements[indexPath.row] as? Actor {
                currentActor = actor
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let mvc = segue.destinationViewController as? MovieDetailViewController {
            mvc.movieDataSource = self
        } else if let mvc = segue.destinationViewController as? PersonViewController {
            mvc.delegate = self
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        elements = []
        tableView.reloadData()
        return true
    }
    
}
