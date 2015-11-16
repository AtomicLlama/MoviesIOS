//
//  LanguagePreferenceSelector.swift
//  Movies
//
//  Created by Mathias Quintero on 11/14/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit

class LanguagePreferenceSelector: UITableViewController {
    
    var user: User?
    
    var preferences = [LanguagePreference.OriginalLanguage, LanguagePreference.Subtitled, LanguagePreference.SubOrOriginal, LanguagePreference.Dubbed, LanguagePreference.SubOrDub, LanguagePreference.NotCare]

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
        let cell = tableView.dequeueReusableCellWithIdentifier(user?.languagePreference == preferences[indexPath.row] ? "optionSelected": "option", forIndexPath: indexPath)
        cell.textLabel?.text = preferences[indexPath.row].rawValue
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        user?.languagePreference = preferences[indexPath.row]
        tableView.reloadData()
    }

}
