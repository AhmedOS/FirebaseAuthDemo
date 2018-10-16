//
//  Extensions.swift
//  FirebaseDemo
//
//  Created by Ahmed Osama on 10/16/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func fade(y: CGFloat, alphaValue: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alphaValue
            self.frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.width, height: self.frame.height)
        })
    }
}
