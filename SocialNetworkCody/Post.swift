//
//  Post.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-04.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import Foundation
import Firebase


class Post {
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _userId: String!
    private var _profilePicUrl: String!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var userId: String {
        return _userId
    }
    
    var profilePicUrl: String {
        return _profilePicUrl
    }
    
    
    init(caption:String, imageUrl: String, likes: Int, userId: String, profilePicUrl: String ) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        self._userId = userId
        self._profilePicUrl = profilePicUrl
    }
    
    init(postKey: String , postData: Dictionary<String, AnyObject> ) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String  {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let userId = postData["userId"] as? String {
            self._userId = userId
        }
        
        if let profilePicUrl = postData["profilePicUrl"] as? String {
            self._profilePicUrl = profilePicUrl
        }
      
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = likes + 1
        } else {
            _likes = likes - 1
        }
        _postRef.child("likes").setValue(_likes)
        
    }
}

