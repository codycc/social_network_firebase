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

class SignInVC: UIViewController {
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //SIGNING IN WITH FACEBOOK 
    @IBAction func facebookBtnTapped(_ sender: AnyObject) {
        
        // setting up the facebook manager constant
        let facebookLogin = FBSDKLoginManager()
        
        // request permissions to email address, from the facebook view controller
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("CODY: Unable to authenticate with Facebook  - \(error)")
                // handle if the permission is cancelled
            } else if result?.isCancelled == true {
                print("CODY: User cancelled facebook authentication")
            } else {
                print("CODY: Successfully authenticated with Facebook")
                
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
                print("CODY: Unable to authenticate with Firebase -\(error)")
            } else {
                print("CODY: Successfully authenticated with Firebase")
            }
        })
    }
    
    //SIGNING IN/UP WITH EMAIL/PASSWORD
    @IBAction func signInTapped(_ sender: AnyObject) {
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("CODY1: Email user authenticated with Firebase")
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("CODY1: Unable to authenticated with Firebase using email")
                        } else {
                            print("CODY1: Successfully signed up (authenticated) with Firebase")
                        }
                    })
                }
            })
        }
    }

}

