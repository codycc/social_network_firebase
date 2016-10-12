//
//  ProfileVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-07.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    
    var posts = [Post]()
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild("posts") {
                DataService.ds.REF_USER_CURRENT.child("posts").observe(.value, with: { (snapshot) in
                    // need to clear out the posts array when the app is interacted with otherwise posts will be duplicated from redownloading
                    self.posts = []
                    // snapshot will now grab all objects
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        
                        // for every post object ie "kldjfkjdls" : "true"
                        for snap in snapshot {
                            print("SNAP: \(snap)")
                            // grab the key of that post and search for it in your posts database
                            let post = DataService.ds.REF_POSTS.child(snap.key)
                            print("THE POST NOW:\(post)")
                            // now grab the snapshot of that specific post
                            post.observeSingleEvent(of: .value, with: { (snapshot) in
                                // set it up as a dictionary with string and any object
                                if let postValue = snapshot.value as? Dictionary <String, AnyObject> {
                                    print("POST VALUE:\(postValue)")
                                    // the key will be the key of that post
                                    let key = snapshot.key
                                    // create a post instance with the new data
                                    let post = Post(postKey: key, postData: postValue)
                                    // add that post into the array
                                    self.posts.append(post)
                                    print("HERE IS THE THING IN ARRAY:\(post.caption)")
                                    
                                }
                               
                            })
                            
                        }
                        
                    }
                   
                })
                
            } else {
                print("user doesnt have any posts")
               
            }
           
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
           self.tableView.reloadData()
       
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
       
     
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let post = posts[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as? ProfileCell {
             
                if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                print("THIS IS THE POST FROM CELL:\(post)")
                    cell.configureCell(post: post, img: img)
                } else {
                    cell.configureCell(post: post)
                    
                }
                return cell
            } else {
                return ProfileCell()
            }
    }
    
       
   
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

   
}
