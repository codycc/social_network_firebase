//
//  FeedVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-09-29.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOutTapped(_ sender: AnyObject) {
        // When signing out ... remove keychain ID
        let keychainResult2 = KeychainWrapper.defaultKeychainWrapper().removeObjectForKey(KEY_UID)
        print("CODY1: ID removed from keychain \(keychainResult2)")
        //Signout from firebase
        try! FIRAuth.auth()?.signOut()
        // Go back to login screen
        self.dismiss(animated: true, completion: nil)
        
    }

}
