//
//  StreamingTableViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 5/16/16.
//  Copyright © 2016 LS1 TUM. All rights reserved.
//

import UIKit

class StreamingTableViewController: UITableViewController {
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    var delegate: MovieDetailDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        title = "Streaming Options"
        tableView.tableFooterView = UIView(frame: CGRectZero)
        delegate?.currentMovieForDetail()?.fetchStreamingLinks() { () in
            self.tableView.reloadData()
            self.spinner.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if delegate?.currentMovieForDetail()?.linksLoaded ?? false {
            if delegate?.currentMovieForDetail()?.streamingLinks.isEmpty ?? false {
                return 1
            }
            return delegate?.currentMovieForDetail()?.streamingLinks.count ?? 0
        }
        return delegate?.currentMovieForDetail()?.streamingLinks.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if delegate?.currentMovieForDetail()?.linksLoaded ?? true && delegate?.currentMovieForDetail()?.streamingLinks.isEmpty ?? false {
            let cell = tableView.dequeueReusableCellWithIdentifier("error", forIndexPath: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("link", forIndexPath: indexPath)
        cell.textLabel?.text = delegate?.currentMovieForDetail()?.streamingLinks[indexPath.row].0
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if delegate?.currentMovieForDetail()?.streamingLinks.isEmpty ?? true {
            return
        }
        if let link = delegate?.currentMovieForDetail()?.streamingLinks[indexPath.row].1, url = NSURL(string: link) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

}
