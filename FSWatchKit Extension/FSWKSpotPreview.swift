//
//  FSWKSpotPreview.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/15/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import Foundation

struct FSWKSpotPreview: Hashable, Equatable {
    var id: Int
    var name: String
    var county: String
    
    init(id: Int, name: String, county: String) {
        self.id = id
        self.name = name
        self.county = county
    }
    
    var hashValue: Int {
        return id.hashValue
    }
}

func ==(lhs: FSWKSpotPreview, rhs: FSWKSpotPreview) -> Bool {
    return lhs.id == rhs.id
}
