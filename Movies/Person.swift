//
//  Person.swift
//  Movies
//
//  Created by Mathias Quintero on 1/23/16.
//  Copyright © 2016 LS1 TUM. All rights reserved.
//

import Foundation
import UIKit

open class Person {
    let name: String
    let id: String
    var image: UIImage?
    
    init(name: String, id: String) {
        self.id = id
        self.name = name
    }
    
    init(name: String, id: String, image: UIImage?) {
        self.id = id
        self.name = name
        self.image = image
    }
    
}
