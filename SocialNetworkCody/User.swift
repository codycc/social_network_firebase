//
//  User.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-10-25.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import Foundation
import Firebase

class User {
    private var _username: String!
    private var _provider: String!
    private var _profilePicUrl: String!
    private var _coverPhotoUrl: String!
    private var _userKey: String!
    private var _userRef: FIRDatabaseReference!
    private var _cityBorn: String!
    private var _currentCity: String!
    private var _workplace: String!
    private var _followerCount: Int!
    private var _followingCount: Int!
    
    var username: String {
        return _username
    }
    
    var provider: String {
        return _provider
    }
    
    var profilePicUrl: String {
        return _profilePicUrl
    }
    
    var coverPhotoUrl: String {
        return _coverPhotoUrl
    }
    
    var userKey: String {
        return _userKey
    }
    
    var cityBorn: String {
        return _cityBorn
    }
    
    var currentCity: String {
        return _currentCity
    }
    
    var workplace: String {
        return _workplace
    }
    
    var followerCount: Int {
        return _followerCount
    }
    
    var followingCount: Int {
        return _followingCount
    }
    
    
    
    init(username: String, provider: String, profilePicUrl: String, coverPhotoUrl: String, cityBorn: String, currentCity: String, workplace: String) {
        self._username = username
        self._provider = provider
        self._profilePicUrl = profilePicUrl
        self._coverPhotoUrl = coverPhotoUrl
        self._cityBorn = cityBorn
        self._currentCity = currentCity
        self._workplace = workplace
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>) {
        self._userKey = userKey
        
        if let username = userData["username"] as? String {
            self._username = username
        }
        
        if let provider = userData["provider"] as? String {
            self._provider = provider
        }
        if let cityBorn = userData["city-born"] as? String {
            self._cityBorn = cityBorn
        }
        
        if let currentCity = userData["current-city"] as? String {
            self._currentCity = currentCity
        }
        
        if let profilePicUrl = userData["profile-pic"] as? String {
            self._profilePicUrl = profilePicUrl
        }
        
        if let coverPhotoUrl = userData["coverPhotoUrl"] as? String {
            self._coverPhotoUrl = coverPhotoUrl
        }
        
        if let workplace = userData["workplace"] as? String {
            self._workplace = workplace
        }
        
        if let followerCount = userData["follower-count"] as? Int {
            self._followerCount = followerCount
        }
        
        if let followingCount = userData["following-count"] as? Int {
            self._followingCount = followingCount
        }
        
        _userRef = DataService.ds.REF_USERS.child(_userKey)
    }
    
    func adjustFollowersCount(addFollowerCount: Bool) {
        if addFollowerCount {
            _followerCount = followerCount + 1
        } else {
            _followerCount = followerCount - 1
        }
        _userRef.child("follower-count").setValue(_followerCount)
    }
    
    func adjustFollowingCount(addFollowingCount: Bool) {
        if addFollowingCount {
            _followingCount = followingCount + 1
        } else {
            _followingCount = followingCount - 1
        }
        _userRef.child("following-count").setValue(_followingCount)
    }
    
    
}
