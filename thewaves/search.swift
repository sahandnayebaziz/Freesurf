//
//  search.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 9/26/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import Foundation

extension String {
    func contains(other: String) -> Bool{
        var start = startIndex
        do{
            var subString = self[Range(start: start++, end: endIndex)].lowercaseString
            if subString.hasPrefix(other.lowercaseString){
                return true
            }
            
        }while start != endIndex
        return false
    }
}