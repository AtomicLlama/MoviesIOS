//
//  BuyTicketsViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 1/23/16.
//  Copyright © 2016 LS1 TUM. All rights reserved.
//

import UIKit
import GMStepper
class BuyTicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func returnToBuyTicketsView(segue:UIStoryboardSegue) {
        if let mvc = segue.sourceViewController as? FriendListTableViewController, friend = mvc.selectedFriend {
            people.append(friend)
            tableView.reloadData()
        }
    }

    @IBOutlet weak var tableView: UIExpandableTableView!
    
    var stepper: StepperTableViewCell?
    
    var tickets: Double {
        get {
            return stepper?.stepper.value ?? 0
        }
    }
    
    var showtime: Showtime?
    
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Buy Tickets"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Constants.tintColor
        tableView.tableFooterView = UIView(frame: CGRectZero)
        if let mvc = tabBarController as? MoviesTabBarController, let user = mvc.currentUser {
            people.append(user.toPerson())
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.tableView.sectionOpen != NSNotFound && section == self.tableView.sectionOpen) {
            switch section {
            case 0: return 1
            case 1: return people.count + (people.count < Int(tickets) ? 1 : 0)
            default: return 0
            }
        }
        return 0
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "How many Tickets?"
        case 1: return "Who's coming?"
        case 2: return "Where do you want to sit?"
        default: return "Buy Tickets"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("stepper") as? StepperTableViewCell ?? StepperTableViewCell()
            cell.backgroundColor = UIColor.clearColor()
            stepper = cell
            return cell
        case 1:
            if indexPath.row < people.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("friend") as? FriendTableViewCell ?? FriendTableViewCell()
                cell.backgroundColor = UIColor.clearColor()
                cell.person = people[indexPath.row]
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("add") ?? UITableViewCell()
                cell.backgroundColor = UIColor.clearColor()
                return cell
            }
        default: break
        }
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView(tableView: self.tableView, section: section)
        headerView.backgroundColor = UIColor.whiteColor()
        let label = UILabel(frame: headerView.frame)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        label.textColor = Constants.tintColor
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row > 0 && indexPath.row < people.count
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let handler = { (action: UITableViewRowAction, indexPath: NSIndexPath) in
            self.people.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        let action = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Remove", handler: handler)
        return [action]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController.childViewControllers.first as? FriendListTableViewController, let mvc = tabBarController as? MoviesTabBarController, let user = mvc.currentUser {
            dvc.user = user
            dvc.doNotInclude = people
        }
    }

}
