//
//  CommentCell.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-12.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase

class CommentCell: UITableViewCell {
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    var comment: Comment!
    
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
        
        
        
    }
  

}
