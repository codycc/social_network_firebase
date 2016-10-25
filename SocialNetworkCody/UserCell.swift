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
        usernameLbl.text = user.username
        
        
        if img != nil {
            self.profileImg.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: user.profilePicUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CODY!: Unable to download image from firebase storage")
                } else {
                    print("Cody1: Image downloaded from firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data:imgData) {
                            self.profileImg.image = img
                            SearchVC.imageCache.setObject(img, forKey: user.profilePicUrl as NSString)
                        }
                    }
                }
            })
        }
    }

}
