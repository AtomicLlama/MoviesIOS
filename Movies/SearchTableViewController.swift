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
    
    //Array of popular films to suggest the user before typing
    
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
        
        //Immediatly select the search textfield
        
        searchTextField.becomeFirstResponder()
        searchTextField.delegate = self
        
        //Fixing issues with Cell sizes
        
        tableView.rowHeight = (CGFloat) (140)
        
        //Make sure there are no white separator lines after the items
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.backgroundColor = UIColor(red:0.82, green:0.44, blue:0.39, alpha:1)
        
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    var results = [String:[AnyObject]]()    //Cached searches to avoid too many requests after deleting letters
    
    //Should be deallocated of the memory after you go back to the featured view.
    
    var elements = [AnyObject]()    //Actors and Movies returned by search
    
    func parseData(searchString: String?) {
        
        //Safely making url for the request
        
        if let searchQuery =  searchString?.stringByReplacingOccurrencesOfString(" ", withString: "+").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()) {
            
            let url = "http://api.themoviedb.org/3/search/multi?api_key=18ec732ece653360e23d5835670c47a0&query=" + searchQuery
            
            // Make request
            
            Alamofire.request(.GET, url).responseJSON() { (response) in
                
                //Don't suggest a new Movie to search if it previously wasn't showing anything.
                
                var refresh = self.elements.count != 0
                
                //Reinitialize
                
                self.elements = []
                
                //Cast results as array
                
                if let body = response.result.value as? [String:AnyObject], results = body["results"] as? [AnyObject] {
                    if results.count != 0 {
                        
                        //Iterate through the first 10 items in the array
                        
                        for i in 0...min(results.count-1,9) {
                            
                            //Cast item as JSON Object and get media type to create the proper object
                            
                            if let parsedItem = results[i] as? [String:AnyObject], medium = parsedItem["media_type"] as? String {
                                
                                //Check if it's a movie or a person
                                
                                if medium == "movie" {
                                    let movieAsDictionary = parsedItem
                                    
                                    //Get Movie Data
                                    
                                    if let id = movieAsDictionary["id"] as? Int, title = movieAsDictionary["title"] as? String, plot = movieAsDictionary["overview"] as? String, year = movieAsDictionary["release_date"] as? String, rating = movieAsDictionary["vote_average"] as? Double, poster = movieAsDictionary["poster_path"] as? String {
                                        
                                        //Check if movie was cached
                                        
                                        if let alreadyKnownMovie = self.delegate?.knownMovie(id.description) {
                                            self.elements.append(alreadyKnownMovie)
                                            self.tableView.reloadData()
                                        } else {
                                            
                                            //Create object
                                            
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
                                    
                                    //Get person data
                                    
                                    if let actorID = parsedItem["id"] as? Int, name = parsedItem["name"] as? String {
                                        
                                        //Check if person was cached
                                        
                                        if let knownPerson = self.delegate?.knownPerson(actorID.description) {
                                            self.elements.append(knownPerson)
                                            if i == min(results.count-1,5) {
                                                self.results[searchString!] = self.elements
                                            }
                                        } else {
                                            
                                            //Create object
                                            
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
                                
                                //Cache Results to minimize damage on network when deleting characters
                                
                                if i == min(results.count-1,9) {
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
                
                //If there were previously movies, and now there aren't, refresh to get a new Suggestion
                
                if refresh {
                    self.tableView.reloadData()
                }
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
        
        //If the change isn't meaningless make a search
        
        if string != " " {
            
            //Check what the change means
            
            let replaced = NSString(string: textField.text ?? "").stringByReplacingCharactersInRange(range, withString: string)
            if  replaced != "" {
                
                //If the result isn't empty check if we cached something for it
                
                if let prevResult = results[replaced] {
                    elements = prevResult
                    tableView.reloadData()
                } else {
                    
                    //Search for our new query!!!
                    
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
            
            //Create cell and suggest something randomly
            
            let cell = tableView.dequeueReusableCellWithIdentifier("welcome") ?? UITableViewCell()
            cell.textLabel?.numberOfLines = 0
            var text = "I'm here to help.\nJust Type Away!\nWhat Are you waiting for?"
            if let movieTitle = popFilm?[(Int) (random()) % (popFilm?.count ?? 0)].title {
                if (Int) (random())%2 == 0 {
                    text = "Search for \"" + movieTitle + "\", maybe...\nI've heard it's good."
                }
            }
            
            //Make sure it looks nice!
            
            cell.textLabel?.text = text
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            return cell
        } else {
            
            //Check the current element and return the proper Cell
            
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
        
        //Satisfying Compiler!
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Point selector to new item and hide Keyboard
        
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
        
        //Set self as delegate of the next view!
        
        if let mvc = segue.destinationViewController as? MovieDetailViewController {
            mvc.movieDataSource = self
        } else if let mvc = segue.destinationViewController as? PersonViewController {
            mvc.delegate = self
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        
        //If text is clearing delete elements and reload.
        
        elements = []
        tableView.reloadData()
        return true
    }
    
}
