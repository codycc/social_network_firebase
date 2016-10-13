//
//  Comment.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-12.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    private var _comment: String!
    private var _userId: String!
    private var _postId: String!
    private var _commentRef: FIRDatabaseReference!
    private var _commentKey: String!
    
    var comment: String {
        return _comment
    }
    
    var userId: String {
        return _userId
    }
    
    var postId: String {
        return _postId
    }
    
    var commentKey: String {
        return _commentKey
    }
    
    init(comment: String, userId: String, postId: String) {
        self._postId = postId
        self._userId = userId
        self._comment = comment
    }
    
    // grabbing the information from firebase and setting it equal to the variables
    init(commentKey: String, commentData: Dictionary< String,AnyObject>) {
        self._commentKey = commentKey
        
        if let comment = commentData["comment"] as? String {
            self._comment = comment
        }
        
        if let userId = commentData["userId"] as? String {
            self._userId = userId
        }
        
        if let postId = commentData["postId"] as? String {
            self._postId = postId
        }
        
        _commentRef = DataService.ds.REF_COMMENTS.child(_commentKey)
    }
    
}
