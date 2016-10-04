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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
       
        // observing for any changes in the posts object in firebase
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            // going through every snapshot
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                //for every snap in the snapshot
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    // setting the value of each snap as a postDict
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        //setting constants of key and post
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        //adding each post to the posts array 
                        self.posts.append(post)
                    }
                }
                self.tableView.reloadData()
            }
        })
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        print("CODY1: \(post.caption)")
        
        return tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
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
