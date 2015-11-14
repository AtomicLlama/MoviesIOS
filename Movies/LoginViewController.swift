//
//  LoginViewController.swift
//  Movies
//
//  Created by Mathias Quintero on 11/13/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            performSegueWithIdentifier("loggedIn", sender: self)
        } else {
            self.loginButton?.alpha = 1.0
            self.welcomeLabel.alpha = 1.0
            self.logoImageView.alpha = 1.0
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        print("Will Log In")
        self.loginButton?.alpha = 0.0
        self.welcomeLabel.alpha = 0.0
        self.logoImageView.alpha = 0.0
        return true
    }
    
    var isFirstLoad = true
    
    var loginButton: FBSDKLoginButton?

    override func viewDidLoad() {
        let frame = CGRectMake(view.center.x, view.center.y, view.frame.width - 80, (view.frame.width - 80)/4.5)
        loginButton = FBSDKLoginButton(frame: frame)
        loginButton!.center = CGPoint(x: view.center.x, y: view.center.y + 70)
        loginButton!.alpha = 0.0
        loginButton?.readPermissions = ["public_profile","email", "user_friends"]
        loginButton?.delegate = self
        view.addSubview(loginButton!)
    }
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            let effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.alpha = 0.5
            let frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.width, imageView.frame.height + 100)
            effectView.frame = frame
            imageView.addSubview(effectView)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBOutlet weak var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.alpha = 0.0
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoad {
            UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.loginButton?.alpha = 1.0
                self.welcomeLabel.alpha = 1.0
                self.logoImageView.frame.origin.y -= 60
                }, completion: nil)
            isFirstLoad = false
        } else {
            self.logoImageView.frame.origin.y -= 60
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Performing Segue")
    }
}
