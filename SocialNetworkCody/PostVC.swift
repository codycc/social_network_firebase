//
//  PostVC.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-12.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit
import Firebase
class PostVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postCaption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var post: Post!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userId = post.userId
        
        DataService.ds.REF_USERS.child(userId).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            let username = snapshot.value
            self.usernameLbl.text = username as! String?
        })
        
        self.postCaption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        // Downloading post image
            let img = PostVC.imageCache.object(forKey: post.imageUrl as NSString)
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
                                PostVC.imageCache.setObject(img, forKey: self.post.imageUrl as NSString)
                            }
                        }
                    }
                })
            }
        
        
        //Downloading profile image
        let profile = PostVC.imageCache.object(forKey: post.profilePicUrl as NSString)
        
        if profile != nil {
            self.profileImg.image = profile
        } else {
            // otherwise create the image from firebase storage
            let ref = FIRStorage.storage().reference(forURL: post.profilePicUrl)
            // max size aloud
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CODY!: Unable to download image Firebase storage")
                } else {
                    print("CODY!: Image downloaded from firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profileImg.image = img
                            // setting the cache now
                            PostVC.imageCache.setObject(img, forKey: self.post.profilePicUrl as NSString)
                        }
                    }
                }
            })
        }
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

 
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
