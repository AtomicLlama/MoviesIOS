//
//  ShowtimesDataFetcher.swift
//  Movies
//
//  Created by Mathias Quintero on 12/27/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
class ShowtimesDataFetcher:NSObject, CLLocationManagerDelegate {
    
    static let locationManager = CLLocationManager()
    
    static var knownTheatres = [String:Theatre]()
    
    var movie: Movie?
    
    var handler: (() -> ())?
    
    var user: User?
    
    var date = NSDate() {
        didSet {
            request = nil
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        ShowtimesDataFetcher.locationManager.stopUpdatingLocation()
        updated()
    }
    
    var request: Request?
    
    func getDaysFromNow() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let difference = calendar.components(.Day, fromDate: NSDate(), toDate: date, options: [])
        return difference.day
    }
    
    func updated() {
        let location = ShowtimesDataFetcher.locationManager.location
        if let locationUnwrapped = location, unwrappedMovie = movie {
            let baseURL = "http://moviesbackend.herokuapp.com/showtimes/" + unwrappedMovie.id.description
            if let url = (baseURL + "?lon=" + locationUnwrapped.coordinate.longitude.description + "&lat=" + locationUnwrapped.coordinate.latitude.description + (getDaysFromNow() < 1 ? "" : "&date=" + getDaysFromNow().description)).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet()), id = user?.id, token = user?.token  {
                if request == nil {
                    request = Alamofire.request(.GET, url).authenticate(user: id, password: token).responseJSON() { (response) in
                        if let times = response.result.value as? [AnyObject] {
                            let dateformatter = NSDateFormatter()
                            dateformatter.dateFormat = "yyyy MM dd "
                            let dateString = dateformatter.stringFromDate(self.date)
                            for item in times {
                                if let data = item as? [String:AnyObject], name = data["name"] as? String, address = data["name"] as? String, film = data["film"] as? String, times = data["showtimes"] as? [AnyObject] {
                                    var theatre: Theatre
                                    if let knownTheatre = ShowtimesDataFetcher.knownTheatres[name] {
                                        theatre = knownTheatre
                                    } else {
                                        theatre = Theatre(name: name, location: address)
                                        ShowtimesDataFetcher.knownTheatres[name] = theatre
                                    }
                                    for time in times {
                                        dateformatter.dateFormat = "yyyy MM dd HH:mm"
                                        if let moment = time as? String, date = dateformatter.dateFromString(dateString + moment) {
                                            let showtime = Showtime(name: film, time: date, theatre: theatre)
                                            self.movie?.addTime(showtime)
                                        } else {
                                            dateformatter.dateFormat = "yyyy MM dd HH:mma"
                                            if let moment = time as? String, date = dateformatter.dateFromString(dateString + moment) {
                                                let showtime = Showtime(name: film, time: date, theatre: theatre)
                                                self.movie?.addTime(showtime)
                                            }
                                        }
                                    }
                                }
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                self.handler?()
                            }
                        } else {
                            self.movie?.addTime(NullShowtime(time: self.date))
                            dispatch_async(dispatch_get_main_queue()) {
                                self.handler?()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if let m = movie, h = handler {
            fetchMovieTimes(m, handler: h, date: date, user: user)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        manager.stopUpdatingLocation()
        manager.startUpdatingLocation()
    }
    
    func fetchMovieTimes(movie: Movie, handler: () -> (), date: NSDate, user: User?) {
        ShowtimesDataFetcher.locationManager.delegate = self
        self.movie = movie
        self.handler = handler
        self.date = date
        self.user = user
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            ShowtimesDataFetcher.locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Denied && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.NotDetermined {
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                ShowtimesDataFetcher.locationManager.startUpdatingLocation()
            }
        }
    }
    
}