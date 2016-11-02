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
    
    var date = Date() {
        didSet {
            request = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        ShowtimesDataFetcher.locationManager.stopUpdatingLocation()
        updated()
    }
    
    var request: Request?
    
    func getDaysFromNow() -> Int {
        let calendar = Calendar.current
        let difference = (calendar as NSCalendar).components(.day, from: Date(), to: date, options: [])
        return difference.day!
    }
    
    func updated() {
        let location = ShowtimesDataFetcher.locationManager.location
        if let locationUnwrapped = location, let unwrappedMovie = movie {
            let baseURL = "http://moviesbackend.herokuapp.com/showtimes/" + unwrappedMovie.id.description
            if let url = (baseURL + "?lon=" + locationUnwrapped.coordinate.longitude.description + "&lat=" + locationUnwrapped.coordinate.latitude.description + (getDaysFromNow() < 1 ? "" : "&date=" + getDaysFromNow().description)).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed), let id = user?.id, let token = user?.token  {
                if request == nil {
                    request = Alamofire.request(url).authenticate(user: id, password: token).responseJSON() { (response) in
                        if let times = response.result.value as? [AnyObject] {
                            let dateformatter = DateFormatter()
                            dateformatter.dateFormat = "yyyy MM dd "
                            let dateString = dateformatter.string(from: self.date)
                            for item in times {
                                if let data = item as? [String:AnyObject], let name = data["name"] as? String, let address = data["name"] as? String, let film = data["film"] as? String, let times = data["showtimes"] as? [AnyObject] {
                                    var theatre: Theatre
                                    if let knownTheatre = ShowtimesDataFetcher.knownTheatres[name] {
                                        theatre = knownTheatre
                                    } else {
                                        theatre = Theatre(name: name, location: address)
                                        ShowtimesDataFetcher.knownTheatres[name] = theatre
                                    }
                                    for time in times {
                                        dateformatter.dateFormat = "yyyy MM dd HH:mm"
                                        if let moment = time as? String, let date = dateformatter.date(from: dateString + moment) {
                                            let showtime = Showtime(name: film, time: date, theatre: theatre)
                                            self.movie?.addTime(showtime)
                                        } else {
                                            dateformatter.dateFormat = "yyyy MM dd HH:mma"
                                            if let moment = time as? String, let date = dateformatter.date(from: dateString + moment) {
                                                let showtime = Showtime(name: film, time: date, theatre: theatre)
                                                self.movie?.addTime(showtime)
                                            }
                                        }
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                self.handler?()
                            }
                        } else {
                            self.movie?.addTime(NullShowtime(time: self.date))
                            DispatchQueue.main.async {
                                self.handler?()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let m = movie, let h = handler {
            fetchMovieTimes(m, handler: h, date: date, user: user)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        manager.stopUpdatingLocation()
        manager.startUpdatingLocation()
    }
    
    func fetchMovieTimes(_ movie: Movie, handler: @escaping () -> (), date: Date, user: User?) {
        ShowtimesDataFetcher.locationManager.delegate = self
        self.movie = movie
        self.handler = handler
        self.date = date
        self.user = user
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
            ShowtimesDataFetcher.locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.notDetermined {
            let queue = DispatchQueue(label: "io.popcorn", qos: .userInitiated, target: nil)
            queue.async {
                ShowtimesDataFetcher.locationManager.startUpdatingLocation()
            }
        }
    }
    
}
