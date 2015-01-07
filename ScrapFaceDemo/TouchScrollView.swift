//
//  TouchScrollView.swift
//  ScrapFaceDemo
//
//  Created by Fumitoshi Ogata on 2015/01/05.
//  Copyright (c) 2015年 Fumitoshi Ogata. All rights reserved.
//

import Foundation
import UIKit

class TouchScrollView: UIScrollView {
    
    var rootView : ViewController!
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.rootView?.toucheBegan(touches)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        self.rootView?.touchMove(touches)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.rootView?.touchEnd(touches)
    }
}


class PhotoUIImageView: UIImageView {
    
    //var rootView : ViewController!
    /*
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.rootView?.toucheBegan(touches)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        self.rootView?.touchMove(touches)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.rootView?.touchEnd(touches)
    }*/
}

