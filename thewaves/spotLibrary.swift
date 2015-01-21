//
//  spotLibrary.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit
import Alamofire

// a SpotLibrary object holds all surf weather data used at runtime.
// :: the SpotLibrary class has arrays and dictionaries that store the data, "get--" methods that make HTTP requests to the Spitcast API
//    to store the data, and helper methods for accessing the stored data from consuming views.
class SpotLibrary: NSObject, NSURLSessionDelegate {
    
    // allCountyNames is the receiving array used in the first HTTP request method getCounties.
    // :: allCountyNames will store the name of each county containing a spot in the Spitcast directory one time, as the name appears in Spitcast
    var allCountyNames:[String] = []
    
    // allSpotIDs is the receiving array used in the HTTP request getSpotsInCounties
    // :: allSpotIDs will store the Spitcast ID integer for each active spot that is listed for a given county
    var allSpotIDs:[Int] = []
    
    // selectedSpotIDs holds the Spitcast ID's for the surf spots that the user has selected in the searchForNewSpots controller
    var selectedSpotIDs:[Int] = []
    
    // logs that keep track of which data points have been requested for spots and counties
    var spotRequestDictionary:[Int:(name:Bool, county:Bool, heights:Bool, conditions:Bool)] = [:]
    var countyRequestDictionary:[String:(waterTemp:Bool, tides:Bool, swells:Bool, wind:Bool)] = [:]
    
    // spotDataDictionary holds of a tuple of surf spot swell data (value) for each surf spot ID (key)
    // :: spotDataDictionary is initialized to be empty when each spot ID is seen in the app for the first time
    var spotDataDictionary:[Int:(spotName:String, spotCounty:String, spotHeights:[Float]?, spotConditions:String?)] = [:]
    
    // countyDataDictionary holds a tuple of county weather data (value) for each county name (key)
    // :: values in the tuple are optionals because at runtime, an HTTP request is made to Spitcast for these values
    //    and we may not receive this data for a noticable amount of time. Optionals allow us to plan ahead and
    //    gracefully handle the absence of these values
    var countyDataDictionary:[String:(waterTemp:Int?, tides:[Float]?, swells:[(height:Int, period:Int, direction:String)]?, wind:(speedInMPH:Int, direction:String)?)] = [:]
    
    // currentHour is an integer representing the current hour of the day in 24-hour time
    // :: midnight is "0" and 11PM is "23"
    var currentHour:Int = NSDate().hour()
    
    // callLog holds a list of the parameters that have been requested from Spitcast (value) for a given county or spot (key)
    // :: callLog keeps track of every request we send out to ensure that no request is sent out twice while waiting for a value to be saved
    //    in the spotDataDictionary or countyDataDictionary
    var callLog:[String:[String]] = [:]
    
    // MARK: Storing data from Spitcast
    
    // getCounties loops through a list of all surf spots Spitcast offers data for and saves each county that is listed in this response once in allCountyNames
    // :: county names are stored, and then a request is made (getSpotsInCounties) for the listed spots in each county. I found the /spot/all endpoint
    //    to return spots that are not currently actively monitored by Spitcast (as of December 2014). Where the /spot/all response may contain 30 spots listed as an "Orange County" spot,
    //    only some of those will have data. Saving the list of spots that is returned by the /county/spots/orange-county/ endpoint will return only the spots that are active. This seems to be
    //    true for all counties in Spitcast.
    //
    // :: This method runs when the app is opened on a separate thread from the UI.
    func getCounties() {
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/all")!
        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonData, error) in
                if jsonData != nil {
                    let data = JSON(jsonData!)
                    let numberOfSpotsInJSONResponse = data.count
                    for var index = 0; index < numberOfSpotsInJSONResponse; index++ {
                        if let countyName:String = data[index]["county_name"].string {
                            self.initializeCountyDataEntriesIfNeeded(countyName)
                        }
                        else {
                            NSLog("A county name could not be read.")
                        }
                    }
                    self.getSpotsInCounties(self.allCountyNames)
                }
        }
    }
    
    // getSpotsInCounties loops through a list of all the active spots for a given county in the Spitcast database and creates an entry for the spot in the spotDataDictionary
    // :: this method has an extra responsiblity in that it must gracefully fill the spotDataDictionary while not overwriting any of the data that was added to the
    //    dictionary at initialization from NSUserDefaults. when the app enters the background, exportLibraryToString() is called on the spotLibrary object held in
    //    YourSpotsTableViewController, and the IDs, names, and counties of the selected spots are written to a string saved in NSUserDefaults. This string is
    //    unwrapped and turned into a SpotLibrary library object with a spotDataDictionary and countyDataDictionary initialized with just enough data on the user's selected spots
    //    to start making HTTP requests for spot and county data. In the case that data for a specific spot has already been stored as getSpotsInCounties is scraping the Spitcast list of spots
    //    in a county and comes up to the same specific spot we've already stored data for, the data should be preserved. This saves network activity and time.
    // :: getSpotsInCounties is intially called with a list of all the counties found in Spitcast. This method makes a request for data with the first element in the list of counties.
    //    When the callback runs and finishes, getSpotsInCounties pops the first county
    //    and calls itself again with the rest of the list of counties. This continues until all counties have been requested and popped off of the list.
    func getSpotsInCounties(counties:[String]) {
        
        // if the list of counties is not empty
        if counties.count > 0 {
            var county = counties[0]
            let countyString:String = counties[0].stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
            let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/spots/\(countyString)/")!
            
            Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
                .responseJSON { (request, response, jsonData, error) in
                    if jsonData != nil {
                        let data = JSON(jsonData!)
                        let numberOfSpotsInCounty = data.count
                        
                        // get spot data
                        var id:Int? = nil
                        var name:String = ""
                        var spotCounty:String = county
                        for var index = 0; index < numberOfSpotsInCounty; index++ {
                            if let newSpotID:Int = data[index]["spot_id"].int {
                                id = newSpotID
                            } else { NSLog("The id could not be pulled for a spot in \(county)") }
                            
                            if let newSpotName:String = data[index]["spot_name"].string {
                                name = newSpotName
                            } else { NSLog("The name could not be pulled for a spot in \(county)") }
                        }
                        
                        if id != nil {
                            if (!contains((self.allSpotIDs), id!)) {
                                self.allSpotIDs.append(id!)
                                self.spotDataDictionary[id!] = (name, spotCounty, nil, nil)
                                self.spotRequestDictionary[id!] = (name:true, county:true, heights:false, conditions:false)
                            }
                        }
                        var newCounties = counties
                        newCounties.removeAtIndex(0)
                        self.getSpotsInCounties(newCounties)
                    }
            }
        }
        else {
            NSLog("stored all spots")
        }
    }
    
    // getSpotSwell takes a spotID and saves a list of forecasted swell heights for the next 24 hours for this spot with one entry for each hour
    func getSpotSwellsForToday(spotID:Int) {
        
        // the array we will store the new data in before storing the array in the correct key in spotDataDictionary
        var hoursOfSwellHeights:[Float] = []
        
        // the string we will store the spot conditions in before storing the string in the correct key in spotDataDictionary
        var currentConditionsString:String? = nil
        
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(spotID)")!
        
        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonData, error) in
                if jsonData != nil {
                    let data = JSON(jsonData!)
                    
                    for var index = 0; index < 24; index++ {
                        if let swellHeight = data[index]["size_ft"].float {
                            hoursOfSwellHeights.append(swellHeight)
                        } else { NSLog("a swell height could not be logged for spot \(spotID)") }
                    }
                    
                    if let conditions:String = data[0]["shape_full"].string { currentConditionsString = conditions }
                    else { NSLog("spot conditions could not be logged for spot \(spotID)") }
                    
                    if currentConditionsString != nil { self.spotDataDictionary[spotID]!.spotConditions = currentConditionsString }
                    if hoursOfSwellHeights.count > 0 { self.spotDataDictionary[spotID]!.spotHeights = hoursOfSwellHeights }
                }
                
                self.spotRequestDictionary[spotID]!.conditions = true
                self.spotRequestDictionary[spotID]!.heights = true
        }
        
    }
    
    // getCountyWaterTemp takes the name of a county and saves the county's current water temperature in countyDataDictionary
    func getCountyWaterTemp(county:String) {
        let countyString:String = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/water-temperature/\(countyString)/")!
        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonData, error) in
                if jsonData != nil {
                    let data = JSON(jsonData!)
                    
                    if let temp = data["fahrenheit"].int { self.countyDataDictionary[county]!.waterTemp = temp }
                    else { NSLog("county water temperature could not be logged for \(county))") }
                }
                
                self.countyRequestDictionary[county]!.waterTemp = true
        }
    }
    
    // getCountyTideForToday takes a county and saves a list of forecasted tide levels for every hour of the current day
    func getCountyTideForToday(county:String) {
        
        // the array we will store the new data in before storing the array in the correct key in countyDataDictionary
        var tideLevelsForToday:[Float] = []
        
        // format the name of county into the format Spitcast can understand
        let countyString:String = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/tide/\(countyString)/")!
        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonData, error) in
                if jsonData != nil {
                    let data = JSON(jsonData!)
                    
                    for var index = 0; index < 24; index++ {
                        if let tide = data[index]["tide"].float { tideLevelsForToday.append(tide) }
                        else { NSLog("county tide could not be logged for \(county))") }
                    }
                    
                    if tideLevelsForToday.count > 0 { self.countyDataDictionary[county]!.tides = tideLevelsForToday }
                }
                
                self.countyRequestDictionary[county]!.tides = true
        }
        
    }
    
    // getCountySwell takes a county and saves the county's current swells in countyDataDictionary
    func getCountySwell(county:String) {
        
        // the array we will store the new data in before storing the array in the correct key in spotDataDictionary
        var newListOfSwells:[(height:Int, period:Int, direction:String)] = []
        
        // format the name of the county into the format Spitcast can understand
        let countyString:String = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/swell/\(countyString)/")!
        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonData, error) in
                if jsonData != nil {
                    let data = JSON(jsonData!)
                    
                    let possibleKeys = ["0", "1", "2", "3", "4", "5"]
                    // Spitcast organizes the 6 possible sources of swell in keys "0", "1", ... , "5" in their JSON. Each key does not always have data,
                    // so each key must be checked. If the key contains swell data, the data will be saved into countyDataDictionary
                    for (var x = 0; x < 5; x++) {
                        
                        var direction:Int? = nil
                        var height:Float? = nil
                        var period:Float? = nil
                        
                        if let directionInDegrees:Int = data[self.currentHour][possibleKeys[x]]["dir"].int {
                            direction = directionInDegrees
                        }
                        else {

                        }
                        
                        if let heightInMeters:Float = data[self.currentHour][possibleKeys[x]]["hs"].float {
                            height = heightInMeters
                        }
                        else {

                        }
                        
                        if let periodInSeconds:Float = data[self.currentHour][possibleKeys[x]]["tp"].float {
                            period = periodInSeconds
                        }
                        else {
                            
                        }
                        
                        // if all data is present for this key, the data will be saved into a tuple, into countyDataDictionary
                        if direction != nil && height != nil && period != nil {
                            
                            // Spitcast responds with the data meters. Here, this value is converted into feet
                            var heightInFeet:Int = self.swellMetersToFeet(height!)
                            
                            // degreesToDirection is used to convert the direction of a swell in degrees (270°)
                            var directionInHeading:String = self.degreesToDirection(direction!)
                            
                            // periodAsInt converts the float value to an integer
                            var periodAsInt:Int = Int(period!)
                            
                            // store the data into the temporary list
                            newListOfSwells += [(height:heightInFeet, period:periodAsInt, direction:directionInHeading)]
                        }
                    }
                    
                    // store this data into countyDataDictionary
                    if newListOfSwells.count > 0 {
                        self.countyDataDictionary[county]!.swells = newListOfSwells
                    }
                }
                
                self.countyRequestDictionary[county]!.swells = true
        }
        
    }
    
    // getCountyWind takes a county and saves the county's current wind data in countyDataDictionary
    func getCountyWind(county:String) {
        
        // format the name of the county into the format Spitcast can understand
        let countyString:String = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        
        let dataURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/wind/\(countyString)/")!
        Alamofire.request(.GET, dataURL, parameters: nil, encoding: .JSON)
            .responseJSON { (request, response, jsonData, error) in
                if jsonData != nil {
                    let data = JSON(jsonData!)
                    
                    var speed:Float? = nil
                    var direction:String? = nil
                    
                    // store data from Spitcast into temporary variables
                    if let newSpeed = data[self.currentHour]["speed_mph"].float {
                        speed = newSpeed
                    }
                    else {
                        NSLog("county wind could not be logged for \(county))")
                    }
                    
                    if let newDirection:String = data[self.currentHour]["direction_text"].string {
                        direction = newDirection
                    }
                    else {
                        NSLog("county wind could not be logged for \(county))")
                    }
                    
                    // store this data into countyDataDictionary
                    if speed != nil && direction != nil {
                        let newWindData = (speedInMPH:Int(speed!), direction: direction!)
                        self.countyDataDictionary[county]!.wind = newWindData
                    }
                }
                
                // log
                self.countyRequestDictionary[county]!.wind = true
        }
        
        
    }
    
    // MARK: initializing data entries
    // initializeCountyDataEntriesIfNeeded takes a county and creates empty entries where necessary in countyDataDictionary.
    // :: this method comes in handy because the user can save spots as they desire and it's unknown at compile time if the app
    //    will see a county's name first while initializing a SpotLibrary object from NSUserDefaults or when storing counties
    //    into allCountyNames at launch.
    func initializeCountyDataEntriesIfNeeded(countyName:String) {
        if (!contains(self.allCountyNames, countyName)) {
            // add this county to allCountyNames
            self.allCountyNames.append(countyName)
            
            // create a key for this county in countyDataDictionary
            self.countyDataDictionary[countyName] = (waterTemp:nil, tides:nil, swells:nil, wind:nil)
            
            // create a key for this county in the countyRequestDictionary
            self.countyRequestDictionary[countyName] = (waterTemp:false, tides:false, swells:false, wind:false)
        }
    }
    
    // MARK: getting data for a spotID
    // name takes takes the id of a spot and returns the spot's name
    func name(id:Int) -> String { return self.spotDataDictionary[id]!.spotName }
    
    // county takes takes the id of a spot and returns the county the spot belongs to
    func county(id:Int) -> String { return self.spotDataDictionary[id]!.spotCounty }
    
    // currentHeight takes the id of a spot and returns the spot's forecasted swell height for the current hour as an integer
    // if swell data has been stored
    func currentHeight(id:Int) -> Int? {
        if let height:Float = self.spotDataDictionary[id]!.spotHeights?[0] {
            return Int(height)
        }
        else {
            return nil
        }
    }
    
    // currentConditions takes the id of a spot and returns a string description of the spot's current conditions
    // if swell data has been stored
    func currentConditions(id:Int) -> String? {
        if let conditions:String = self.spotDataDictionary[id]!.spotConditions {
            return conditions
        }
        else {
            return nil
        }
    }
    
    // MARK: getting data for a county
    // waterTemp takes the id of a spot and returns the current water temperature of the spot's county if the water temperature
    // has been stored for the county
    func waterTemp(id:Int) -> Int? {
        return self.countyDataDictionary[self.county(id)]?.waterTemp
    }
    
    // tidesForToday takes the id of a spot and returns a list of the forecasted tide levels of the spot's county for the
    // next 24 hours if tide data has been stored for the county
    func tidesForToday(id:Int) -> [Float]? { return self.countyDataDictionary[self.county(id)]!.tides }
    
    // heightsForToday takes the id of a spot and returns a list of the forecasted swell heights for the spot for the next 24 hours
    // if the tide data has been stored for the county
    func heightsForToday(id:Int) -> [Float]? { return self.spotDataDictionary[id]!.spotHeights }
    
    // swells takes the id of a spot and returns a list of the swells currently affecting the spot's county if swell data
    // has been stored for the county
    func swells(id:Int) -> [(height:Int, period:Int, direction:String)]? { return self.countyDataDictionary[self.county(id)]!.swells }
    
    // wind takes the id of a spot and returns the wind currently affect the spot's county if wind data has been stored for the county
    func wind(id:Int) -> (speedInMPH:Int, direction:String)? { return self.countyDataDictionary[self.county(id)]!.wind }
    
    // significantSwell takes the id of a spot and returns data for only the most significant swell affecting the spot's county
    // if swell data has been stored for the county.
    // :: The most significant swell is chosen by finding the swell with the largest significant height (Hs), or the swell
    //    that is strongest.
    func significantSwell(id:Int) -> (height:Int, period:Int, direction:String)? {
        if let swells = self.countyDataDictionary[self.county(id)]!.swells {
            
            // this value is initialzied as the first swell in the list
            var mostSignificantSwell = swells[0]
            
            // loop through the rest of the swells in the list and compare their heights with the default mostSignificantSwell, swell[0].
            // update mostSignificantSwell if another swell has a stronger height
            for var index = 1; index < swells.count; index++ {
                if swells[index].height > mostSignificantSwell.height {
                    mostSignificantSwell = swells[index]
                }
            }
            
            return mostSignificantSwell
        }
        else {
            return nil
        }
    }
    
    // getValuesForYourSpotsCell takes the id of a spot and returns a tuple of data that can be consumed by an instance of YourSpotsCell for this spot
    // if all data for this spot has been stored and it is safe to display this cell to the user and allow the cell to be tapped for more detail.
    func getValuesForYourSpotsCell(id: Int) -> (height:Int, waterTemp:Int, swell:(height:Int, period:Int, direction:String))? {
        
        // getValuesForYourSpotsCell returns a tuple of values only when everything we use to display data about a spot, both within a YourSpotsCell and
        // SpotDetail
        if self.currentHeight(id) != nil && self.waterTemp(id) != nil && self.tidesForToday(id) != nil && self.significantSwell(id) != nil && self.wind(id) != nil {
            return (height: self.currentHeight(id)!, waterTemp: self.waterTemp(id)!, swell:self.significantSwell(id)!)
        }
        else {
            return nil
        }
    }
    
    func allRequestsMade(id: Int) -> (height:Int?, waterTemp:Int?, swell:(height:Int, period:Int, direction:String)?)? {
        var spotRequests = self.spotRequestDictionary[id]
        var countyRequests = self.countyRequestDictionary[self.county(id)]
        
        if spotRequests != nil && countyRequests != nil {
            
            if spotRequests!.heights && spotRequests!.conditions && countyRequests!.waterTemp && countyRequests!.swells {
                return (height: self.currentHeight(id)?, waterTemp: self.waterTemp(id)?, swell:self.significantSwell(id)?)
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
        
    }
    
    // MARK: serialization and de-serialization of a SpotLibrary object
    // exportLibraryToString serializes the self-instance of a SpotLibrary object into a string.
    // :: this comes in handy to save the information about a user's state, or the spots they have selected to be displayed,
    //    easily into NSUserDefaults by writing just enough information about their instance of a SpotLibrary to a string, to
    //    unwrap the string the next time they launch the app and show them that their selected spots have been saved.
    func exportLibraryToString() -> String {
        var exportString:String = ""
        
        // for each selectedspot, the id, name, and county is saved and added to the exportString. exportString is the string
        // that will be returned. exportString will contain spot data that is separated by a comma from spot to spot and by a
        // period from value to value for each spot.
        for spotID in self.selectedSpotIDs {
            exportString += "\(spotID).\(name(spotID)).\(county(spotID)),"
        }
        
        return exportString
    }
    
    // initLibraryFromString deserializes a string and unwraps the data written in the string into values in the self-instance SpotLibrary object
    // :: this comes in handy to restore the information saved about a user's state, or the spots they have selected to be displayed, into the current SpotLibrary
    //    object immediately at launch.
    func initLibraryFromString(exportString: String) {
        
        // the serialized string separates spot substrings by commas. Here, the spot substrings are separated and stored into an array
        var listOfSpotExports:[String] = exportString.componentsSeparatedByString(",")
        
        for spotExport in listOfSpotExports {
            // within each spot substring, the spot's id, name, and county are separated by periods. Here, these values are separated and stored into the SpotLibrary object.
            var spotAttributes:[String] = spotExport.componentsSeparatedByString(".")
            
            // if the particular spot substring was unwrapped successfully and as expected with three pieces (id, name, county), proceed and restore this information
            if spotAttributes.count == 3 {
                let spotID:Int = spotAttributes[0].toInt()!
                let spotName:String = spotAttributes[1]
                let spotCounty:String = spotAttributes[2]
                
                // create all data entries for this spot
                self.allSpotIDs.append(spotID)
                self.selectedSpotIDs.append(spotID)
                self.spotDataDictionary[spotID] = (spotName, spotCounty, nil, nil)
                self.spotRequestDictionary[spotID] = (name: true, county: true, heights: false, conditions: false)
                
                // create all data entries for this county if one has not been made
                initializeCountyDataEntriesIfNeeded(spotCounty)
            }
        }
    }
    
    // MARK: math operations for spot and swell data
    // swellMetersToFeet takes a floating pointer number representing a distance in meters and returns an integer representing that distance in feet
    func swellMetersToFeet(height:Float) -> Int { return Int(height * 3.2) }
    
    // degreesToDirection takes a degree (0° ... 359°) and returns a string representing that degree as the abbreviation of a cardinal direction (NE, SW, S) using compass directions
    func degreesToDirection(degrees:Int) -> String {
        if degrees == 0 || degrees == 360 {
            return "S"
        }
        else if degrees == 90 {
            return "W"
        }
        else if degrees == 180 {
            return "N"
        }
        else if degrees == 270 {
            return "E"
        }
        else if degrees > 0 && degrees < 90 {
            return "SW"
        }
        else if degrees > 90 && degrees < 180 {
            return "NW"
        }
        else if degrees > 180 && degrees < 270 {
            return "NE"
        }
        else if degrees > 270 && degrees < 360 {
            return "SE"
        }
        else {
            return " "
        }
    }
}



























