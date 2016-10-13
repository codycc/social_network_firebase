//
//  PostCell.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-09-29.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var editPostBtn: UIButton!
    
    
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

        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        self.caption.isEditable = false 
        
        // grab the user id of that post
         let postUser = post.userId
        // search through users by that specific id and access the username
            let userNickname = DataService.ds.REF_USERS.child(postUser).child("username")
        // grab value of username and set the label accordinly 
        userNickname.observeSingleEvent(of: .value, with: { (snapshot) in
             print(snapshot)
            self.usernameLbl.text = snapshot.value as! String?
        })
        
        
      
        
        
        // grabbing profile image from cache or downloading it from the url
        if profileImage != nil {
            self.profileImg.image = profileImage
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.profilePicUrl)
            
            ref.data(withMaxSize: 2 * 1024 * 1024 , completion: { (data, error) in
                if error != nil {
                    print("cody!: unable to download image firebase storage")
                } else {
                    print("cody!: image downloaded fromfirebase storage ")
                    if let imgData = data {
                        if let postProfilePic = UIImage(data: imgData) {
                            self.profileImg.image = postProfilePic
                            FeedVC.imageCache.setObject(postProfilePic, forKey: post.profilePicUrl as NSString)
                        }
                    }
                }
            })
        }
        

        // if theres an img from the cache then set the image
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
                        FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                    }
                 }
              }
           })
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
       
        
        
    }
}
