//
//  FSWKSpotData.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/15/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import Foundation

struct FSWKSpotData: Hashable, Equatable {
    var id: Int
    var height: Int
    
    init(id: Int, height: Int) {
        self.id = id
        self.height = height
    }
    
    var hashValue: Int {
        return id.hashValue
    }
}

func ==(lhs: FSWKSpotData, rhs: FSWKSpotData) -> Bool {
    return lhs.id == rhs.id
}
