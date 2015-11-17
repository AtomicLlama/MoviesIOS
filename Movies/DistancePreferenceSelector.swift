//
//  DistancePreferenceSelector.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class DistancePreferenceSelector: UITableViewController {

    var user: User?
    
    var preferences = [1,2,3,4,5,7,10,15,20,50]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferences.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(user?.distanceRange == preferences[indexPath.row])
        let cell = tableView.dequeueReusableCellWithIdentifier(user?.distanceRange == preferences[indexPath.row] ? "optionSelected": "option", forIndexPath: indexPath)
        cell.textLabel?.text = preferences[indexPath.row].description + " km"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        user?.distanceRange = preferences[indexPath.row]
        tableView.reloadData()
    }


}
