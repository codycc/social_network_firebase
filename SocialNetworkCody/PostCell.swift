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
    
    var post: Post!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // ui image with default value as nil
    func configureCell(post:Post, img: UIImage? = nil ) {
        self.post = post
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
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
    }
    

}
