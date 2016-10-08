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

    var post: Post!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(post: Post) {
        self.post = post 
        self.captionField.text = post.caption
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
