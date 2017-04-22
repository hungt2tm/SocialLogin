//
//  ViewController.swift
//  NewLogin
//
//  Created by Unlocked on 4/20/17.
//  Copyright © 2017 Unlocked. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import TwitterKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFacebookButton()
        setupGoogleButton()
        setupTwitterButton()
        
    }
    
    fileprivate func setupTwitterButton() {
        let twitterButton = TWTRLogInButton { (session, error) in
            if let err = error {
                print("Failed to login via Twitter: ", err)
                return
            }
            
            //lets login with Firebase
            guard let token = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            let  credentials = FIRTwitterAuthProvider.credential(withToken: token
                , secret: secret)
            
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                if let err = error {
                    print("Failed to login to Firebase with Twitter: ", err)
                }
                print("Successfully created a Firebase-Twitter user: ", user?.uid ?? "")
            })
        }
        
        view.addSubview(twitterButton)
        twitterButton.frame = CGRect(x: 16, y: 116 + 66 + 66 + 66, width: view.frame.width - 32, height: 50)
    }
    
    fileprivate func setupGoogleButton() {
        //add google sign in button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        
        //add custom google button
        let customGoogle = UIButton(type: .system)
        customGoogle.frame = CGRect(x: 16, y: 116 + 66 + 66, width: view.frame.width - 32, height: 50)
        customGoogle.backgroundColor = .orange
        customGoogle.setTitle("Custom Google Sign In", for: .normal)
        customGoogle.setTitleColor(.white, for: .normal)
        customGoogle.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        customGoogle.addTarget(self, action: #selector(handleCustomGoogleSign)
            , for: .touchUpInside)
        view.addSubview(customGoogle)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func handleCustomGoogleSign() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    fileprivate func setupFacebookButton() {
        let btnLogin = FBSDKLoginButton()
        view.addSubview(btnLogin)
        btnLogin.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        btnLogin.delegate = self
        btnLogin.readPermissions = ["email", "public_profile"]
        
        //add our custom fb login button here
        let customFBButton = UIButton()
        customFBButton.backgroundColor = .blue
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        customFBButton.setTitle("Custom FB Login here", for: .normal)
        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(customFBButton)
        
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
    func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"]
        , from: self) { (result, err) in
            if err != nil {
                print("Cusstom FB Login failed", err!)
                return
            }
            
            self.showEmailAddress()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith
        result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        showEmailAddress()
    }
    
    func showEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {
            return
        }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }
            
            print("Successfully logged in with our user: ", user ?? "")
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"])
            .start { (connection, result, err) in
                if err != nil {
                    print("Failed to start graph request", err ?? "")
                    return
                }
                print(result ?? "")
        }
    }
    
}

