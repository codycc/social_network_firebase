//
//  PostVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-12.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class PostVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {
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
        commentField.delegate = self
        // setting up the information from the didselectrow, taking from sender and setting up views and labels
        let userId = post.userId
        DataService.ds.REF_USERS.child(userId).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            let username = snapshot.value
            self.usernameLbl.text = username as! String?
        })
        self.postCaption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        let url = URL(string: self.post.imageUrl)
        self.postImg.kf.setImage(with: url)
        
        let profileUrl = URL(string: self.post.profilePicUrl)
        self.profileImg.kf.setImage(with: profileUrl)
        
        self.retrieveComments()
        
    }
    
    //FOR KEYBOARD EDITING
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
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
    
    func retrieveComments() {
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

 
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    // when i want to comment, it'll grab the info out of the textfield, set it accordingly
    // when the post button is tapped, call post to firebase
    @IBAction func postBtnTapped(_ sender: AnyObject) {
        //close keyboard
        self.view.endEditing(true)
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
