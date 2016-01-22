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
    
    func getDaysFromNow(date: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let difference = calendar.components(.Day, fromDate: NSDate(), toDate: date, options: [])
        return difference.day
    }
    
    var currentDate = NSDate() {
        didSet {
            let days = getDaysFromNow(currentDate)
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEEE"
            if days == 0 {
                barButton?.title = "Today"
            } else if days < 7 {
                barButton?.title = formatter.stringFromDate(currentDate)
            } else {
                formatter.dateFormat = "EEE dd MMM"
                barButton?.title = formatter.stringFromDate(currentDate)
            }
        }
    }
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    lazy var datePicker:THDatePickerViewController = {
        var dp = THDatePickerViewController.datePicker()
        dp.delegate = self
        dp.setAllowClearDate(false)
        dp.setClearAsToday(true)
        dp.setAutoCloseOnSelectDate(false)
        dp.setAllowSelectionOfSelectedDate(true)
        dp.setDisableHistorySelection(true)
        dp.setDisableFutureSelection(false)
        dp.selectedBackgroundColor = Constants.tintColor
        dp.currentDateColor = Constants.tintColor
        dp.currentDateColorSelected = UIColor.whiteColor()
        return dp
    }()
    
    func selectDate(sender: AnyObject?) {
        datePicker.date = currentDate
        datePicker.setDateHasItemsCallback() { (date: NSDate!) -> Bool in
            return self.getDaysFromNow(date) >= 0
        }
        presentSemiViewController(datePicker, withOptions: [
            convertCfTypeToString(KNSemiModalOptionKeys.shadowOpacity) as String! : 0.3 as Float,
            convertCfTypeToString(KNSemiModalOptionKeys.animationDuration) as String! : 0.3 as Float,
            convertCfTypeToString(KNSemiModalOptionKeys.pushParentBack) as String! : false as Bool
            ])
        
    }
    
    func datePickerDonePressed(datePicker: THDatePickerViewController!) {
        dismissSemiModalView()
    }
    
    func datePicker(datePicker: THDatePickerViewController!, selectedDate: NSDate!) {
        if getDaysFromNow(selectedDate) >= 0 {
            currentDate = selectedDate
            reload()
            loadForDate()
            dismissSemiModalView()
        }
    }
    
    func datePickerCancelPressed(datePicker: THDatePickerViewController!) {
        dismissSemiModalView()
    }
    
    func convertCfTypeToString(cfValue: Unmanaged<NSString>!) -> String?{
        /* Coded by Vandad Nahavandipoor */
        let value = Unmanaged<CFStringRef>.fromOpaque(
            cfValue.toOpaque()).takeUnretainedValue() as CFStringRef
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
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.backgroundColor = Constants.tintColor
        barButton = UIBarButtonItem(title: "Today", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("selectDate:"))
        navigationItem.rightBarButtonItem = barButton
        loadForDate()
    }
    
    func loadForDate() {
        if let unwrappedMovie = movie {
            if unwrappedMovie.getTimesForDate(currentDate).isEmpty {
                spinner.startAnimating()
                fetcher.fetchMovieTimes(unwrappedMovie, handler: self.reload, date: currentDate)
            } else {
                reload()
            }
        } else {
            reload()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        reOrder()
    }
    
    func reload() {
        spinner.stopAnimating()
        if let _  = movie?.getTimesForDate(currentDate).first as? NullShowtime {
            timesForTheatre = []
            noTimes = true
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
        tableView.separatorColor = noTimes ? UIColor.clearColor() : UIColor.whiteColor()
        tableView.reloadData()
    }
    
    func reOrder() {
        if let location = locationManager.location {
            timesForTheatre.sortInPlace() { (a,b) in
                return a.0.location.distanceFromLocation(location) < b.0.location.distanceFromLocation(location)
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if noTimes {
            return 1
        }
        return timesForTheatre.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noTimes {
            return 1
        }
        return timesForTheatre[section].1.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if noTimes {
            return nil
        }
        return timesForTheatre[section].0.name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if noTimes {
            let cell = tableView.dequeueReusableCellWithIdentifier("error") ?? UITableViewCell()
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("time") as? MovieTimeTableViewCell ?? MovieTimeTableViewCell()
        cell.item = timesForTheatre[indexPath.section].1[indexPath.row]
        cell.posterImage.image = movie?.poster
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            header.textLabel?.textColor = Constants.tintColor
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !noTimes
    }

}
