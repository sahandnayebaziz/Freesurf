//
//  Colors.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/20/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

import UIKit

struct Colors {
    private static func createColorFrom(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat?) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a != nil ? a! : 1.0)
    }
    
    static var blue: UIColor { return createColorFrom(r: 68, g: 139, b: 252, a: 1) }
}

