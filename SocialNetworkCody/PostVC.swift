//
//  PostVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-12.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase
class PostVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postCaption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentField: UITextField!
    
    var post: Post!
    var comments = [Comment]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // setting up the information from the didselectrow, taking from sender and setting up views and labels
        let userId = post.userId
        DataService.ds.REF_USERS.child(userId).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            let username = snapshot.value
            self.usernameLbl.text = username as! String?
        })
        self.postCaption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        
        // Downloading post image
            let img = PostVC.imageCache.object(forKey: post.imageUrl as NSString)
            if img != nil {
                self.postImg.image = img
            } else {
                // otherwise create the image from firebase storage
                let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
                // max size aloud
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("CODY!: Unable to download image Firebase storage")
                    } else {
                        print("CODY!: Image downloaded from firebase storage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                self.postImg.image = img
                                // setting the cache now
                                PostVC.imageCache.setObject(img, forKey: self.post.imageUrl as NSString)
                            }
                        }
                    }
                })
            }
        
        
        //Downloading profile image
        let profile = PostVC.imageCache.object(forKey: post.profilePicUrl as NSString)
        
        if profile != nil {
            self.profileImg.image = profile
        } else {
            // otherwise create the image from firebase storage
            let ref = FIRStorage.storage().reference(forURL: post.profilePicUrl)
            // max size aloud
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CODY!: Unable to download image Firebase storage")
                } else {
                    print("CODY!: Image downloaded from firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profileImg.image = img
                            // setting the cache now
                            PostVC.imageCache.setObject(img, forKey: self.post.profilePicUrl as NSString)
                        }
                    }
                }
            })
        }
        
        
        
        // going through every comment in the comments database and passing them to the Comment Model to use later 
        // also, taking those comments and passing into the comments array for use in the tableview
        DataService.ds.REF_COMMENTS.observe(.value, with: { (snapshot) in
            // need to clear out the posts array when the app is interacted with otherwise posts will be duplicated from redownloading
            self.comments = []
            // going through every snapshot
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                //for every snap in the snapshot
                for snap in snapshot {
                    print("SNAP: \(snap)")
                   // grab the value for the child postId
                    let postId = snap.childSnapshot(forPath: "postId")
                    // if the value for that specific postId is equal to this post Id on the page, only then can you store it in the array 
                    let postIdValue = postId.value as? String
                    if postIdValue == self.post.postKey {
                        if let commentDict = snap.value as? Dictionary<String, AnyObject> {
                            //setting constants of key and post
                            let key = snap.key
                            let comment = Comment(commentKey: key, commentData: commentDict)
                            //adding each post to the posts array
                            self.comments.append(comment)
                        }
                        
                    }
                    
                  
                }
                
                self.tableView.reloadData()
                
                
                
            }
        })
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? CommentCell {

            cell.configureCell(comment: comment)
            return cell
        } else {
            return PostCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

 
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    // when i want to comment, it'll grab the info out of the textfield, set it accordingly
    // when the post button is tapped, call post to firebase
    @IBAction func postBtnTapped(_ sender: AnyObject) {
        guard let comment = commentField.text, comment != "" else {
            print("CODY1: Comment must be entered")
            return
        }
        self.postToFirebase()
        
    }
    // which will set up the JSON in firebase and set values for the comment, the user who posted it, and post id its for.
    // also will reset the commentfield
    func postToFirebase() {
        let comment: Dictionary<String, Any> = [
            "comment": commentField.text! as String,
            "userId": DataService.ds.REF_USER_CURRENT.key,
            "postId": self.post.postKey
        ]
        // setting the value with whatever is passed into this function
        let firebasePost = DataService.ds.REF_COMMENTS.childByAutoId()
        firebasePost.setValue(comment)
        // resetting the inputs for the post
        commentField.text = ""

        
        // reloading the tableview since new data has now been added to the Firebase Database
        tableView.reloadData()
    }
    
}
