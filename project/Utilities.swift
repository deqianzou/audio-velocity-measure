//
//  Utilities.swift
//  project
//
//  Created by JTDX on 2017/6/19.
//  Copyright © 2017年 texot. All rights reserved.
//

import Foundation
import UIKit

func dispatch_main(closure:@escaping ()->()) {
    DispatchQueue.main.async {
        closure()
    }
}

func dispatch_delay(delay:Double, closure:@escaping ()->()) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

func round_device_scale(d: CGFloat) -> CGFloat
{
    let scale: CGFloat = UIScreen.main.scale
    return round(d * scale) / scale
}
