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
    
    @IBAction func returnToBuyTicketsView(_ segue:UIStoryboardSegue) {
        if let mvc = segue.source as? FriendListTableViewController, let friend = mvc.selectedFriend {
            people.append(friend)
            stepper?.stepper.minimumValue = Double(people.count)
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
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.sectionOpen = 0
        if let mvc = tabBarController as? MoviesTabBarController, let user = mvc.currentUser {
            people.append(user.toPerson())
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.tableView.sectionOpen != NSNotFound && section == self.tableView.sectionOpen) {
            switch section {
            case 0: return 1
            case 1: return people.count + (people.count < Int(tickets) ? 1 : 0)
            default: return 0
            }
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "How many Tickets?"
        case 1: return "Who's coming?"
        case 2: return "Where do you want to sit?"
        default: return "Buy Tickets"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "stepper") as? StepperTableViewCell ?? StepperTableViewCell()
            cell.backgroundColor = UIColor.clear
            stepper = cell
            return cell
        case 1:
            if indexPath.row < people.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "friend") as? FriendTableViewCell ?? FriendTableViewCell()
                cell.backgroundColor = UIColor.clear
                cell.person = people[indexPath.row]
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "add") ?? UITableViewCell()
                cell.backgroundColor = UIColor.clear
                return cell
            }
        default: break
        }
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView(tableView: self.tableView, section: section)
        headerView.backgroundColor = UIColor.white
        let label = UILabel(frame: headerView.frame)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        label.textColor = Constants.tintColor
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row > 0 && indexPath.row < people.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let handler = { (action: UITableViewRowAction, indexPath: IndexPath) in
            self.people.remove(at: indexPath.row)
            if Int(self.tickets) == self.people.count+1 {
                tableView.reloadData()
            } else {
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
            self.stepper?.stepper.minimumValue = Double(self.people.count)
        }
        let action = UITableViewRowAction(style: .default, title: "Remove", handler: handler)
        return [action]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination.childViewControllers.first as? FriendListTableViewController, let mvc = tabBarController as? MoviesTabBarController, let user = mvc.currentUser {
            dvc.user = user
            dvc.doNotInclude = people
        }
    }

}
