//
//  LoginScreenViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 10/21/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import VideoSplash

class LoginScreenViewController: VideoSplashViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("test", ofType: "mp4")!)
        self.videoFrame = view.frame
        self.fillMode = .ResizeAspectFill
        self.alwaysRepeat = true
        self.sound = false
        self.startTime = 12.0
        self.duration = 4.0
        self.alpha = 0.7
        self.backgroundColor = UIColor(red:0.82, green:0.44, blue:0.39, alpha:1)
        self.contentURL = url
    }

}
