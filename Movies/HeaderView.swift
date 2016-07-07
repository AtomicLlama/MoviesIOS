//
//  HeaderView.swift
//  LabelTeste
//
//  Created by Rondinelli Morais on 11/09/15.
//  Copyright (c) 2015 Rondinelli Morais. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: NSObjectProtocol {
    func headerViewOpen(section:Int)
    func headerViewClose(section:Int)
}

class HeaderView: UIView {
    
    var delegate:HeaderViewDelegate?
    var section:Int?
    var tableView:UIExpandableTableView?
    
    required init(tableView:UIExpandableTableView, section:Int){
        
        let height = tableView.delegate?.tableView!(tableView, heightForHeaderInSection: section)
        let frame = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), height!)
        
        super.init(frame: frame)
        
        self.tableView = tableView
        self.delegate = tableView
        self.section = section
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let toggleButton = UIButton()
        toggleButton.addTarget(self, action: #selector(HeaderView.toggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        toggleButton.backgroundColor = UIColor.clearColor()
        toggleButton.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        self.addSubview(toggleButton)
    }
    
    func toggle(sender:AnyObject){
        
        if self.tableView!.sectionOpen != section! {
            self.delegate?.headerViewOpen(section!)
        } else if self.tableView!.sectionOpen != NSNotFound {
            self.delegate?.headerViewClose(self.tableView!.sectionOpen)
        }
    }
}
