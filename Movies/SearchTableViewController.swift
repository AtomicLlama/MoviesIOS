//
//  SearchTableViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 10/18/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

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
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = Constants.tintColor
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextField.resignFirstResponder()
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    var results = [String:[AnyObject]]()    //Cached searches to avoid too many requests after deleting letters
    
    //Should be deallocated of the memory after you go back to the featured view.
    
    var elements = [AnyObject]()    //Actors and Movies returned by search
    
    func parseData(_ searchString: String?) {
        
        //Safely making url for the request
        
        if let searchQuery =  searchString?.replacingOccurrences(of: " ", with: "+").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) {
            
            let url = "http://api.themoviedb.org/3/search/multi?api_key=18ec732ece653360e23d5835670c47a0&query=" + searchQuery
            
            // Make request
            
            Alamofire.request(url).responseJSON() { (response) in
                
                //Don't suggest a new Movie to search if it previously wasn't showing anything.
                
                var refresh = self.elements.count != 0
                
                //Reinitialize
                
                self.elements = []
                
                //Cast results as array
                
                if let body = response.result.value as? [String:AnyObject], let results = body["results"] as? [AnyObject] {
                    if results.count != 0 {
                        
                        //Iterate through the first 10 items in the array
                        
                        for i in 0...min(results.count-1,9) {
                            
                            //Cast item as JSON Object and get media type to create the proper object
                            
                            if let parsedItem = results[i] as? [String:AnyObject], let medium = parsedItem["media_type"] as? String, let id = parsedItem["id"] as? Int {
                                
                                //Check if it's a movie or a person
                                
                                if medium == "movie" {
                                    if let alreadyKnownMovie = self.delegate?.knownMovie(id.description) {
                                        self.elements.append(alreadyKnownMovie)
                                        self.tableView.reloadData()
                                    } else {
                                        if let movie = Mapper<Movie>().map(JSON: parsedItem) {
                                            self.delegate?.learnMovie(id.description, movie: movie)
                                            self.elements.append(movie)
                                            self.tableView.reloadData()
                                        }
                                    }
                                } else if medium == "person" {
                                    if let knownPerson = self.delegate?.knownPerson(id.description) {
                                        self.elements.append(knownPerson)
                                        self.tableView.reloadData()
                                    } else {
                                        if let actor = Mapper<Actor>().map(JSON: parsedItem) {
                                            self.elements.append(actor)
                                            self.delegate?.learnPerson(id.description, actor: actor)
                                        }
                                    }
                                }
                                if i == min(results.count-1,9) {
                                    self.results[searchString!] = self.elements
                                }
                            }
                        }
                    }
                    self.tableView.reloadData()
                    refresh = false
                } else {
                    print("Error Unwrapping Results m" + ((response.result.value as AnyObject).description ?? "Nothing!"))
                    if let body = response.result.value as? [String:AnyObject], let status = body["status_code"] as? Int {
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
    
    func moviesArrived(_ newMovies: [Movie]) {
        return
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //If the change isn't meaningless make a search
        
        if string != " " {
            
            //Check what the change means
            
            let replaced = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if elements.count == 0 {
            tableView.separatorColor = UIColor.clear
        } else {
            tableView.separatorColor = UIColor.white
        }
        return max(elements.count, 1)
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if elements.count == 0 {
            
            //Create cell and suggest something randomly
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "welcome") ?? UITableViewCell()
            cell.textLabel?.numberOfLines = 0
            var text = "I'm here to help.\nJust Type Away!\nWhat Are you waiting for?"
            if let movieTitle = popFilm?[(Int) (arc4random()) % (popFilm?.count ?? 0)].title {
                if (Int) (arc4random())%2 == 0 {
                    text = "Search for \"" + movieTitle + "\", maybe...\nI've heard it's good."
                }
            }
            
            //Make sure it looks nice!
            
            cell.textLabel?.text = text
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.textAlignment = NSTextAlignment.center
            return cell
        } else {
            
            //Check the current element and return the proper Cell
            
            if let actor = elements[indexPath.row] as? Actor {
                let cell = tableView.dequeueReusableCell(withIdentifier: "actor") as? ActorTableViewCell ?? ActorTableViewCell()
                cell.color = UIColor.white
                cell.actor = (actor, actor.bio)
                cell.setUpImageView()
                return cell
            } else if let movie = elements[indexPath.row] as? Movie {
                let cell = tableView.dequeueReusableCell(withIdentifier: "movie") as? ClearMovieTableViewCell ?? ClearMovieTableViewCell()
                cell.movie = movie
                return cell
            }
        }
        
        //Satisfying Compiler!
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Set self as delegate of the next view!
        
        if let mvc = segue.destination as? MovieDetailViewController {
            mvc.movieDataSource = self
        } else if let mvc = segue.destination as? PersonViewController {
            mvc.delegate = self
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        //If text is clearing delete elements and reload.
        
        elements = []
        tableView.reloadData()
        return true
    }
    
}
