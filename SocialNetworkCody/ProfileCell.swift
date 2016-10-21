//
//  ProfileCell.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-07.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase

class ProfileCell: UITableViewCell {
    @IBOutlet weak var postPic: UIImageView!
    @IBOutlet weak var captionField: UITextView!
    @IBOutlet weak var profilePic: UIImageView!

    var post: Post!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(post: Post, img: UIImage? = nil, profileImage: UIImage? = nil) {
        self.post = post 
        self.captionField.text = post.caption
        self.captionField.isEditable = false
        

        // caching post pic
        if img != nil {
            self.postPic.image = img
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
                            self.postPic.image = img
                            // setting the cache now
                            ProfileVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        // caching profile pic
        if profileImage != nil {
            self.profilePic.image = profileImage
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.profilePicUrl)
            
            ref.data(withMaxSize: 2 * 1024 * 1024 , completion: { (data, error) in
                if error != nil {
                    print("cody!: unable to download image firebase storage")
                } else {
                    print("cody!: image downloaded fromfirebase storage ")
                    if let imgData = data {
                        if let postProfilePic = UIImage(data: imgData) {
                            self.profilePic.image = postProfilePic
                            FeedVC.imageCache.setObject(postProfilePic, forKey: post.profilePicUrl as NSString)
                        }
                    }
                }
            })
        }
        
   
        
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
