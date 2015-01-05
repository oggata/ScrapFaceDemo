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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("touchbegan")
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        println("touchmoved")
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("touchended")
    }
}

