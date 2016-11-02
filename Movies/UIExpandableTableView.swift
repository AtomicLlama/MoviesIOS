//
//  UIExpandableTableView.swift
//  LabelTeste
//
//  Created by Rondinelli Morais on 11/09/15.
//  Copyright (c) 2015 Rondinelli Morais. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class UIExpandableTableView : UITableView, HeaderViewDelegate {
    
    var sectionOpen:Int = NSNotFound
    
    // MARK: HeaderViewDelegate
    func headerViewOpen(_ section: Int) {
        
        if self.sectionOpen != NSNotFound {
            headerViewClose(self.sectionOpen)
        }
        
        self.sectionOpen = section
        let numberOfRows = self.dataSource?.tableView(self, numberOfRowsInSection: section) ?? -1
        var indexesPathToInsert:[IndexPath] = []
        
        for i in 0..<numberOfRows {
            indexesPathToInsert.append(IndexPath(row: i, section: section))
        }
        
        if indexesPathToInsert.count > 0 {
            self.beginUpdates()
            self.insertRows(at: indexesPathToInsert, with: UITableViewRowAnimation.automatic)
            self.endUpdates()
        }
    }
    
    func headerViewClose(_ section: Int) {
        
        let numberOfRows = self.dataSource?.tableView(self, numberOfRowsInSection: section) ?? -1 
        var indexesPathToDelete:[IndexPath] = []
        self.sectionOpen = NSNotFound
        
        for i in 0..<numberOfRows {
            indexesPathToDelete.append(IndexPath(row: i, section: section))
        }
        
        if indexesPathToDelete.count > 0 {
            self.beginUpdates()
            self.deleteRows(at: indexesPathToDelete, with: UITableViewRowAnimation.top)
            self.endUpdates()
        }
    }
}
