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
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if FBSDKAccessToken.current() != nil {
            
            if presentingViewController != nil {
                performSegue(withIdentifier: "loggedIn", sender: self)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
                self.dismiss(animated: true, completion: nil)
                appDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBar") as? MoviesTabBarController
            }
            
            
        } else {
            self.loginButton?.alpha = 1.0
            self.welcomeLabel.alpha = 1.0
            self.logoImageView.alpha = 1.0
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        print("Will Log In")
        self.loginButton?.alpha = 0.0
        self.welcomeLabel.alpha = 0.0
        self.logoImageView.alpha = 0.0
        return true
    }
    
    var isFirstLoad = true
    
    var loginButton: FBSDKLoginButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let effectView = UIVisualEffectView(effect: effect)
        let frameForEffect = CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y, width: imageView.frame.width, height: imageView.frame.height + 100)
        effectView.frame = frameForEffect
        imageView.addSubview(effectView)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: effect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.addSubview(welcomeLabel)
        effectView.addSubview(vibrancyView)
        let frame = CGRect(x: view.center.x, y: view.center.y, width: view.frame.width - 80, height: (view.frame.width - 80)/4.5)
        loginButton = FBSDKLoginButton(frame: frame)
        loginButton!.center = CGPoint(x: view.center.x, y: view.center.y + 70)
        loginButton!.alpha = 0.0
        loginButton?.readPermissions = ["public_profile","email", "user_friends"]
        loginButton?.delegate = self
        view.addSubview(loginButton!)
    }
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBOutlet weak var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.alpha = 0.0
        }
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoad {
            UIView.animate(withDuration: 1.0, delay: 0.5, options: UIViewAnimationOptions(), animations: {
                self.loginButton?.alpha = 1.0
                self.welcomeLabel.alpha = 1.0
                self.logoImageView.frame.origin.y -= 60
                }, completion: nil)
            isFirstLoad = false
        } else {
            self.logoImageView.frame.origin.y -= 60
        }
    }
}
