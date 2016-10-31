//
//  CommentCell.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-12.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class CommentCell: UITableViewCell {
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    var comment: Comment!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(comment:Comment) {
        // setting up the cell
        self.comment = comment
        self.commentText.text = comment.comment
        let userId = comment.userId
        
        // grabbing the user id of the specific comment from users database, then grabbing their username to set value
        DataService.ds.REF_USERS.child(userId).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            let user = snapshot.value
            self.usernameLbl.text = user as! String?
        })
        
        
        // Grabbing the specific profile pic from the user who made the comment and then caching it
        DataService.ds.REF_USERS.child(userId).child("profile-pic").observeSingleEvent(of: .value,with: { (snapshot) in
            let url = URL(string: snapshot.value as! String)
            self.profilePic.kf.setImage(with: url)
            
            
//            // Downloading post image
//            let img = PostVC.imageCache.object(forKey: url as! NSString)
//            if img != nil {
//                self.profilePic.image = img
//            } else {
//                // otherwise create the image from firebase storage
//                let ref = FIRStorage.storage().reference(forURL: url as! String)
//                // max size aloud
//                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                    if error != nil {
//                        print("CODY!: Unable to download image Firebase storage")
//                    } else {
//                        print("CODY!: Image downloaded from firebase storage")
//                        if let imgData = data {
//                            if let img = UIImage(data: imgData) {
//                                self.profilePic.image = img
//                                // setting the cache now
//                                PostVC.imageCache.setObject(img, forKey: url as! NSString)
//                            }
//                        }
//                    }
//                })
//            }
        })
        
        
    }
}
