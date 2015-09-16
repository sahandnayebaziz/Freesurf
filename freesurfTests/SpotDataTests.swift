//
//  SpotDataTests.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/15/15.
//  Copyright © 2015 Sahand Nayebaziz. All rights reserved.
//

import XCTest
import CoreLocation

class SpotDataTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSpotDataSerializationWithNil() {
        let original = SpotData(name: "Salt Creek", county: "Orange County", location: nil, heights: nil, conditions: nil)
        let serialized = original.serialized
        let restored = SpotData(serialized: serialized)
        
        XCTAssertEqual(original, restored)
    }
    
    func testSpotDataSerializationWithData() {
        let location = CLLocation(latitude: CLLocationDegrees(33.4608), longitude: CLLocationDegrees(117.6781))
        
        let original = SpotData(name: "Doheny", county: "Orange County", location: location, heights: [4.1], conditions: "poor")
        let serialized = original.serialized
        let restored = SpotData(serialized: serialized)
        
        XCTAssertEqual(original, restored)
    }

}
