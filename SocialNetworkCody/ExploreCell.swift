//
//  ExploreCell.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-11-02.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ExploreCell: UICollectionViewCell {
    
    @IBOutlet weak var userImg: UIImageView!
    
    var user: User!
    
    func configureCell(user: User) {
        print("here is the user cell\(user.profilePicUrl)")
        let url = URL(string: user.profilePicUrl)
        userImg.kf.setImage(with: url)
    }
}
