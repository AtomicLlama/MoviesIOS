//
//  MovieTimesDetailTableViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 12/28/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import CoreLocation
import THCalendarDatePicker

class MovieTimesDetailTableViewController: UITableViewController, CLLocationManagerDelegate, THDatePickerDelegate {
    
    let fetcher = ShowtimesDataFetcher()
    
    let locationManager = CLLocationManager()
    
    var barButton: UIBarButtonItem?
    
    var noTimes = false
    
    func getDaysFromNow(_ date: Date) -> Int {
        let calendar = Calendar.current
        let difference = (calendar as NSCalendar).components(.day, from: Date(), to: date, options: [])
        return difference.day!
    }
    
    var currentDate = Date() {
        didSet {
            let days = getDaysFromNow(currentDate)
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            if days == 0 {
                barButton?.title = "Today"
            } else if days < 7 {
                barButton?.title = formatter.string(from: currentDate)
            } else {
                formatter.dateFormat = "EEE dd MMM"
                barButton?.title = formatter.string(from: currentDate)
            }
        }
    }
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    lazy var datePicker:THDatePickerViewController? = {
        var dp = THDatePickerViewController.datePicker()
        dp?.delegate = self
        dp?.setAllowClearDate(false)
        dp?.setClearAsToday(true)
        dp?.setAutoCloseOnSelectDate(false)
        dp?.setAllowSelectionOfSelectedDate(true)
        dp?.setDisableHistorySelection(true)
        dp?.setDisableFutureSelection(false)
        dp?.selectedBackgroundColor = Constants.tintColor
        dp?.currentDateColor = Constants.tintColor
        dp?.currentDateColorSelected = UIColor.white
        return dp
    }()
    
    func selectDate(_ sender: AnyObject?) {
        datePicker?.date = currentDate
        datePicker?.setDateHasItemsCallback() { (date: Date?) -> Bool in
            return self.getDaysFromNow(date ?? Date()) >= 0
        }
        presentSemiViewController(datePicker, withOptions: [
            convertCfTypeToString(KNSemiModalOptionKeys.shadowOpacity) as String! : 0.3 as Float,
            convertCfTypeToString(KNSemiModalOptionKeys.animationDuration) as String! : 0.3 as Float,
            convertCfTypeToString(KNSemiModalOptionKeys.pushParentBack) as String! : false as Bool
            ])
        
    }
    
    func datePickerDonePressed(_ datePicker: THDatePickerViewController!) {
        dismissSemiModalView()
    }
    
    func datePicker(_ datePicker: THDatePickerViewController!, selectedDate: Date!) {
        if getDaysFromNow(selectedDate) >= 0 {
            currentDate = selectedDate
            reload()
            loadForDate()
            dismissSemiModalView()
        }
    }
    
    func datePickerCancelPressed(_ datePicker: THDatePickerViewController!) {
        dismissSemiModalView()
    }
    
    func convertCfTypeToString(_ cfValue: Unmanaged<NSString>!) -> String?{
        /* Coded by Vandad Nahavandipoor */
        let value = Unmanaged<CFString>.fromOpaque(
            cfValue.toOpaque()).takeUnretainedValue() as CFString
        if CFGetTypeID(value) == CFStringGetTypeID(){
            return value as String
        } else {
            return nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Showtimes"
        locationManager.delegate = self
        spinner.center = view.center
        view.addSubview(spinner)
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = Constants.tintColor
        barButton = UIBarButtonItem(title: "Today", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MovieTimesDetailTableViewController.selectDate(_:)))
        navigationItem.rightBarButtonItem = barButton
        loadForDate()
    }
    
    func loadForDate() {
        movie?.fetchStreamingLinks() { () in
            self.tableView.reloadData()
        }
        if let unwrappedMovie = movie, let mvc = self.tabBarController as? MoviesTabBarController, let user = mvc.currentUser {
            if unwrappedMovie.getTimesForDate(currentDate).isEmpty {
                spinner.startAnimating()
                fetcher.fetchMovieTimes(unwrappedMovie, handler: self.reload, date: currentDate, user: user)
            } else {
                reload()
            }
        } else {
            reload()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        reOrder()
    }
    
    func reload() {
        spinner.stopAnimating()
        if let _  = movie?.getTimesForDate(currentDate).first as? NullShowtime {
            timesForTheatre = []
            noTimes = true && (movie?.linksLoaded ?? false && movie?.streamingLinks.isEmpty ?? false)
        } else {
            noTimes = false
            timesForTheatre = (movie?.getTimesForDate(currentDate).reduce([Theatre]()) { (array,item) in
                var newArray = array
                var isInArray = false
                for theatre in newArray {
                    if theatre.name == item.theatre.name {
                        isInArray = true
                        break
                    }
                }
                if !isInArray {
                    newArray.append(item.theatre)
                }
                return newArray
                } ?? [Theatre]()).map() { (item) in
                    return (item, movie?.getTimesForDate(currentDate).filter() { (time) in
                        return time.theatre.name == item.name
                        } ?? [Showtime]())
            }
            locationManager.startUpdatingLocation()
        }
        tableView.separatorColor = noTimes ? UIColor.clear : UIColor.white
        tableView.reloadData()
    }
    
    func reOrder() {
        if let location = locationManager.location {
            timesForTheatre.sort() { (a,b) in
                return a.0.location.distance(from: location) < b.0.location.distance(from: location)
            }
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var timesForTheatre = [(Theatre,[Showtime])]()
    
    var movie: Movie?

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if noTimes {
            return 1
        }
        if movie?.linksLoaded ?? false {
            if !(movie?.streamingLinks.isEmpty ?? true) {
                return timesForTheatre.count + 1
            }
        }
        return timesForTheatre.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noTimes {
            return 1
        }
        if movie?.linksLoaded ?? false {
            if !(movie?.streamingLinks.isEmpty ?? true) {
                if section == 0 {
                    return movie?.streamingLinks.count ?? 0
                }
                return timesForTheatre[section - 1].1.count
            }
        }
        return timesForTheatre[section].1.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if noTimes {
            return nil
        }
        if movie?.linksLoaded ?? false {
            if !(movie?.streamingLinks.isEmpty ?? true) {
                if section == 0 {
                    return "Streaming Now"
                } else {
                    return timesForTheatre[section-1].0.name
                }
            }
        }
        return timesForTheatre[section].0.name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noTimes {
            let cell = tableView.dequeueReusableCell(withIdentifier: "error") ?? UITableViewCell()
            return cell
        }
        if movie?.linksLoaded ?? false {
            if !(movie?.streamingLinks.isEmpty ?? true) {
                if indexPath.section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "link") as? StreamingItemTableViewCell ?? StreamingItemTableViewCell()
                    cell.service = movie?.streamingLinks[indexPath.row].0
                    cell.posterView.image = movie?.poster
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "time") as? MovieTimeTableViewCell ?? MovieTimeTableViewCell()
                    cell.posterImage.image = movie?.poster
                    cell.item = timesForTheatre[indexPath.section-1].1[indexPath.row]
                    return cell
                }
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "time") as? MovieTimeTableViewCell ?? MovieTimeTableViewCell()
        cell.posterImage.image = movie?.poster
        cell.item = timesForTheatre[indexPath.section].1[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if movie?.linksLoaded ?? false {
            if !(movie?.streamingLinks.isEmpty ?? true) {
                if indexPath.section == 0 {
                    if let link = movie?.streamingLinks[indexPath.row].1, let url = URL(string: link) {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            header.textLabel?.textColor = Constants.tintColor
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return !noTimes
    }

}
