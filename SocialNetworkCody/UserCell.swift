//
//  UserCell.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-25.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(user: User, img: UIImage? = nil) {
        usernameLbl.text = user.username.capitalized
        let url = URL(string: user.profilePicUrl)
        if url != nil {
            profileImg.kf.setImage(with: url)
        } else {
            print("unable to download and cache image with Kingfisher")
        }
    }

}
