//
//  ImageDownloadManager.swift
//  Movies
//
//  Created by Mathias Quintero on 5/29/16.
//  Copyright © 2016 LS1 TUM. All rights reserved.
//

import UIKit
import Alamofire
class ImageDownloadManager {
    
    static var cache = [String:UIImage]()
    
    static func getImageInURL(_ url: String, handler: @escaping (UIImage) -> ()) {
        if let image = cache[url] {
            handler(image)
        } else {
            Alamofire.request(url).responseData() { (response) in
                if let data = response.data, let image = UIImage(data: data) {
                    cache[url] = image
                    handler(image)
                }
            }
        }
    }
    
}
