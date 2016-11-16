//
//  PostCell.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-09-29.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class PostCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var editPostBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var postsRef: FIRDatabaseReference!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // setting up the tap for the heart like button, since its repeated in the cells
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        // it takes one tap to work
        tap.numberOfTapsRequired = 1
        // adding this gesture recognizer to the likes heart
        likeImg.addGestureRecognizer(tap)
        //adding the user interaction
        likeImg.isUserInteractionEnabled = true
    }
    
   
    // ui image with default value as nil
    func configureCell(post:Post, img: UIImage? = nil, profileImage: UIImage? = nil ) {
        self.post = post
        // going to the id of the likkes
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        DispatchQueue.main.async {
            self.caption.text = post.caption
            self.likesLbl.text = "\(post.likes)"
            self.caption.isEditable = false
        }
   
        
        // grab the user id of that post
         let postUser = post.userId
        // search through users by that specific id and access the username
        let userNickname = DataService.ds.REF_USERS.child(postUser).child("username")
        // grab value of username and set the label accordinly 
        userNickname.observeSingleEvent(of: .value, with: { (snapshot) in
             print(snapshot)
            let username = snapshot.value  as! String?
            self.usernameLbl.text = username?.capitalized
        })
        
        
        let url = URL(string: post.imageUrl)
        DispatchQueue.main.async {
            self.postImg.kf.setImage(with: url)
        }
        
       
        let profileUrl = URL(string: post.profilePicUrl)
        DispatchQueue.main.async {
            self.profileImg.kf.setImage(with: profileUrl)
        }
        
        
        // check for the current users likes if anything changes
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            //if null
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
        
        //checking if this is current users post, if so then show edit post button
        DataService.ds.REF_USER_CURRENT.child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(post.postKey) {
                self.editPostBtn.isHidden = false
            } else {
                self.editPostBtn.isHidden = true 
            }
        })
    }
    
    
    
    func likeTapped(sender: UITapGestureRecognizer) {
        // check for the current users likes if anything changes
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            //if null
            
            if let _ = snapshot.value as? NSNull {
                //change the heart image
                self.likeImg.image = UIImage(named: "filled-heart")
                // adjusting the number of likes by one
                self.post.adjustLikes(addLike: true)
                // setting the value of the current users likes, the likes will have every post and true beside it
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                //taking away a like from that post 
                self.post.adjustLikes(addLike: false)
                // remove the value of true under the current users liked posts
                self.likesRef.removeValue()
            }
        })
        
        
        
    }
    
    @IBAction func editPostTapped(_ sender: AnyObject) {
        self.caption.isEditable = true
        self.saveBtn.isHidden = false
    }
    
    @IBAction func saveBtnTapped(_ sender: AnyObject) {
        self.saveBtn.isHidden = true
        let post = self.post!
        self.caption.isEditable = false
        
        // setting the new caption up to be saved in firebase
        let newCaption = self.caption.text as String
        
        // setting up structure for this post
        let postRef = DataService.ds.REF_POSTS.child(post.postKey)
        let newPost: Dictionary<String, Any> = ["caption": newCaption]
        // updating that specific post in firebase
        postRef.updateChildValues(newPost)
        
    }
    
  
}
