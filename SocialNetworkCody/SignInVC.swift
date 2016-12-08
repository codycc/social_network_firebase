//
//  ViewController.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-09-28.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import SwiftKeychainWrapper


class SignInVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!


    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
       // Checking if keychain already exists
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            
            print("CODY1: ID found in keychain")
            // Perform segue if keychain already exists
            performSegue(withIdentifier: "goToFeed", sender: nil)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    

    //SIGNING IN WITH FACEBOOK 
    @IBAction func facebookBtnTapped(_ sender: AnyObject) {
        
        // setting up the facebook manager constant
        let facebookLogin = FBSDKLoginManager()
        
        // request permissions to email address, from the facebook view controller
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("CODY1: Unable to authenticate with Facebook  - \(error)")
                // handle if the permission is cancelled
            } else if result?.isCancelled == true {
                print("CODY1: User cancelled facebook authentication")
            } else {
                print("CODY1: Successfully authenticated with Facebook")
                
                // Grabbing the credential from facebook from facebook, grab the current access token for firebase
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                // passing the credential to the firebaseAuth method
                self.firebaseAuth(credential)
            }
        }
    }
    
    
    //NOTE: add facebook to firebase auth in firebase console -- Done
    
    
    // Using the credential to authenticate with firebase
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("CODY1: Unable to authenticate with Firebase -\(error)")
            } else {
                print("CODY1: Successfully authenticated with Firebase")
                //For keychain sign in
                if let user = user {
                    let userData = ["provider": credential.provider,
                                    "profile-pic": "https://firebasestorage.googleapis.com/v0/b/socialnetworkcody.appspot.com/o/profile-pics%2F60B8721E-B3FE-44A8-B7AE-D7C6596059FE?alt=media&token=3014ef3a-ec02-4bc7-a9ed-1411a3599d24",
                                    "city-born": "Default",
                                    "current-city": "Default",
                                    "workplace": "Default",
                                    "following-count": 0,
                                    "follower-count": 0
                                    ] as [String : Any]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
                
            }
        })
    }
    
    //SIGNING IN/UP WITH EMAIL/PASSWORD
    @IBAction func signInTapped(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("CODY1: Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        
                        self.completeSignIn(id: user.uid, userData: userData)
                        self.performSegue(withIdentifier: "goToFeed", sender: nil)
                    }
                } else {
                    
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("CODY1: Unable to authenticated with Firebase using email")
                        } else {
                            print("CODY1: Successfully signed up (authenticated) with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID,
                                                "profile-pic": "https://firebasestorage.googleapis.com/v0/b/socialnetworkcody.appspot.com/o/profile-pics%2F60B8721E-B3FE-44A8-B7AE-D7C6596059FE?alt=media&token=3014ef3a-ec02-4bc7-a9ed-1411a3599d24",
                                                "city-born": "Default",
                                                "current-city": "Default",
                                                "workplace": "Default",
                                                "following-count": 0,
                                                "follower-count": 0
                                                ] as [String : Any]
                                self.completeSignIn(id: user.uid, userData: userData)
                                self.performSegue(withIdentifier: "goToCustomize", sender: nil)
                            }
                        }
                    })
                }
            })
        }
    }
    
    
    // for existing users function to automatically sign them in
    func completeSignIn(id: String, userData: Dictionary<String,Any>) {
        //passing the text from email field and password into the createfirebasedbuser function in the DataService class
        DataService.ds.createFirebaseDbUser(uid: id, userData: userData)
//        let keychainResult = KeychainWrapper.defaultKeychainWrapper().stringForKey(KEY_UID)
        let keychainResult: Bool = KeychainWrapper.standard.set(id , forKey: KEY_UID)
        print("CODY1: Data saved to keychain \(keychainResult)")
        //Added performSegue here so when the user first signs up, or signs in it will still perform segue
        // Once keychain is set, it wont call this segue, it will call one at viewDidLoad because the keychain exists
        
    }

}

