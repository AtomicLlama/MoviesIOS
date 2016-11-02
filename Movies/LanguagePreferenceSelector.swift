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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferences.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: user?.languagePreference == preferences[indexPath.row] ? "optionSelected": "option", for: indexPath)
        cell.textLabel?.text = preferences[indexPath.row].rawValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        user?.languagePreference = preferences[indexPath.row]
        tableView.reloadData()
    }

}
