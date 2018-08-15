//
//  UIImageView.swift
//  Cloud°
//
//  Created by Jonathan Yu on 7/4/18.
//  Copyright © 2018 Jonathan Yu. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func roundedImage() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
