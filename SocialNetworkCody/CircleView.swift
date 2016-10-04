//
//  CircleView.swift
//  SocialNetworkCody
//
//  Created by Cody Condon on 2016-09-29.
//  Copyright © 2016 Cody Condon. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true 
    }

}
