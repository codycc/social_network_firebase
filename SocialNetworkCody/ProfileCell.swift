//
//  ProfileCell.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-07.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ProfileCell: UITableViewCell {
    @IBOutlet weak var postPic: UIImageView!
    @IBOutlet weak var captionField: UITextView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!

    var post: Post!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    func configureCell(post: Post, img: UIImage? = nil, profileImage: UIImage? = nil) {
        self.post = post 
        self.captionField.text = post.caption
        self.captionField.isEditable = false
        
        
    
//        if let newDate = String(post.date) {
//           print("\(newDate)")
//            let theDate = newDate.replacingOccurrences(of: ".", with: "")
//            print("\(theDate)")
//            if let date = TimeInterval(theDate) {
//                print("\(date)")
//                 let convertedDate = NSDate(timeIntervalSince1970: date)
//                    print("\(convertedDate)")
//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "dd-MM-yyyy"
//                     let formattedDate = formatter.string(from: convertedDate as Date)
//                    self.dateLbl.text = formattedDate
//                    
//                
//            }
//        }
        
        
        
        
        
       
        
      
       
        
        
        // grab the user id of that post
        let postUser = post.userId
        // search through users by that specific id and access the username
        let userNickname = DataService.ds.REF_USERS.child(postUser).child("username")
        // grab value of username and set the label accordinly
        userNickname.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            self.usernameLbl.text = snapshot.value as! String?
        })
        
        let url = URL(string: self.post.imageUrl)
        self.postPic.kf.setImage(with: url)
        
        let profilePic = URL(string: self.post.profilePicUrl)
        self.profilePic.kf.setImage(with: profilePic)
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
