//
//  FollowingCell.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-11-11.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Kingfisher

class FollowingCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    
    func configureCell(user: User) {
        let url = URL(string: user.profilePicUrl)
        print("URL FROM CONFIGURE CELL\(url)")
        if url != nil {
            profileImg.kf.setImage(with: url)
        } else {
            print("unable to download and cache image with KingFisher")
        }
    }
    
}
