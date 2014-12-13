//
//  spotLibrary.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/3/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

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
    
    // spotDataDictionary holds of a tuple of surf spot swell data (value) for each surf spot ID (key)
    // :: spotDataDictionary is initialized to be empty when each spot ID is first seen in the
    var spotDataDictionary:[Int:(spotName:String, spotCounty:String, spotHeights:[Int]?)] = [:]
    
    // countyDataDictionary holds a tuple of county weather data (value) for each county name (key)
    // :: values in the tuple are optionals because at runtime, an HTTP request is made to Spitcast for these values
    //    and we may not receive this data for a noticable amount of time. Optionals allow us to plan ahead and
    //    gracefully handle the absence of these values
    var countyDataDictionary:[String:(waterTemp:Int?, tides:[Int]?, swells:[(height:Int, period:Int, direction:String)]?)] = [:]
    
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
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/all")!
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            
            // begin callback operations
            let numberOfSpotsInJSONResponse = sourceData!.count
            
            for var index = 0; index < numberOfSpotsInJSONResponse; index++ {
                
                // get name of county from Spitcast JSON
                let countyNameForSpot:String = sourceData![index]!["county_name"]! as String
                
                // create entries for this county if they have not yet been made
                // :: an entry may have been made when opening the app and initializing a user's saved spots. See initLibraryFromString()
                self.initializeCountyDataEntriesIfNeeded(countyNameForSpot)
                
            }
            
            // store the spots for each county using getSpotsInCounties()
            self.getSpotsInCounties(self.allCountyNames)
        })
        sourceTask.resume()
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
            let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/spots/\(countyString)/")!
            var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            var sourceData:AnyObject? = nil
            let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
                sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                
                // begin callback operations
                let numberOfSpotsInCounty = sourceData!.count
                
                for var index = 0; index < numberOfSpotsInCounty; index++ {
                    
                    // save values for a spotDataDictionary entry
                    let newSpotID:Int = sourceData![index]!["spot_id"]! as Int
                    let newSpotName:String = sourceData![index]!["spot_name"]! as String
                    let countyNameForSpot:String = sourceData![index]!["county"]! as String
                    
                    // make entries for this spot if they have not yet been made
                    // :: an entry may have been made when opening the app and initializing a user's saved spots. See initLibraryFromString()
                    if (!contains((self.allSpotIDs), newSpotID)) {
                        self.allSpotIDs.append(newSpotID)
                        self.spotDataDictionary[newSpotID] = (newSpotName, countyNameForSpot, nil)
                    }
                    
                }
                
                // pop the county data was just stored for and run getSpotsInCounties with the rest of the counties (passing an empty list is okay)
                var newCounties = counties
                newCounties.removeAtIndex(0)
                self.getSpotsInCounties(newCounties)
            })
            sourceTask.resume()
        }
        else {
            NSLog("stored all spots")
        }
    }
    
    // getSpotSwell takes a spotID and saves a list of forecasted swell heights for the next 24 hours for this spot with one entry for each hour
    func getSpotSwell(spotID:Int) {
        
        // hoursTomorrow is the number of hours left between midnight tonight and 24 hours from the current hour
        // :: this is the number of hours we must store from the Spitcast data for tomorrow
        let hoursTomorrow:Int = self.currentHour
        
        // the array we will store the new data in before storing the array in the correct key in spotDataDictionary
        var next24HoursOfSwellHeights:[Int] = []
        
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(spotID)")!
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            
            // begin callback operation
            
            // store swell heights for now til midnight
            for var index = self.currentHour; index <= 24; index++ {
                next24HoursOfSwellHeights.append(sourceData![index]!["size"] as Int)
            }
            
            // put tomorrow's date into the format Spitcast can understand to return data for tomorrow
            let jsonTomorrowParameter:String = NSDate().dateByAddingDays(1).toString(format: .Custom("yyyyMMdd"))
            
            // make a request for the rest of the heights for tomorrow
            let sourceURLTomorrow:NSURL = NSURL(string: "http://api.spitcast.com/api/spot/forecast/\(spotID)/?dval=" + jsonTomorrowParameter)!
            var sourceSessionTomorrow:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            var sourceDataTomorrow:AnyObject? = nil
            let sourceTaskTomorrow = sourceSessionTomorrow.dataTaskWithURL(sourceURLTomorrow, completionHandler: {(data, response, error) -> Void in
                sourceDataTomorrow = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                
                // store swell heights for midnight tonight til 24 hours from now
                for var index = 0; index < hoursTomorrow; index++ {
                    next24HoursOfSwellHeights.append(sourceData![index]!["size"] as Int)
                }
                
                // save the new data to the spotDataDictionary
                self.spotDataDictionary[spotID]!.spotHeights = next24HoursOfSwellHeights
                
            })
            sourceTaskTomorrow.resume()
            
        })
        sourceTask.resume()
    }
    
    // getCountyWaterTemp takes the name of a county and saves the county's current water temperature in countyDataDictionary
    func getCountyWaterTemp(county:String) {
        self.callLog[county]!.append("CountyWaterTemp") // log this request
        
        let countyString:String = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/water-temperature/\(countyString)/")!
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            
            // begin callback operation
            
            // store the water temperature in countyDataDictionary
            self.countyDataDictionary[county]!.waterTemp = sourceData!["fahrenheit"]! as Int?
        })
        sourceTask.resume()
    }
    
    // getCountyTide takes a county and saves a list of forecasted tide levels for the next 24 hours for this county with one entry for each hour
    func getCountyTide(county:String) {
        
        // logs this request in the callLog
        self.callLog[county]!.append("CountyTide")
        
        // hoursTomorrow is the number of hours left between midnight tonight and 24 hours from the current hour
        // :: this is the number of hours we must store from the Spitcast data for tomorrow
        let hoursTomorrow:Int = self.currentHour
        
        // the array we will store the new data in before storing the array in the correct key in countyDataDictionary
        var next24HoursOfTides:[Int] = []
        
        // format the name of county into the format Spitcast can understand
        let countyString:String = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        
        let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/tide/\(countyString)/")!
        var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var sourceData:AnyObject? = nil
        let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
            sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            
            // begin callback operation
            
            // store tide levels for now til midnight
            for var index = self.currentHour; index <= 24; index++ {
                next24HoursOfTides.append(sourceData![index]!["tide"]! as Int)
            }
            
            // put tomorrow's date into the format Spitcast can understand to return data for tomorrow
            let jsonTomorrowParameter:String = NSDate().dateByAddingDays(1).toString(format: .Custom("yyyyMMdd"))
            
            // make a request for the rest of the heights for tomorrow
            let sourceURLTomorrow:NSURL = NSURL(string: "http://api.spitcast.com/api/county/tide/\(countyString)/?dval=" + jsonTomorrowParameter)!
            var sourceSessionTomorrow:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            var sourceDataTomorrow:AnyObject? = nil
            let sourceTaskTomorrow = sourceSessionTomorrow.dataTaskWithURL(sourceURLTomorrow, completionHandler: {(data, response, error) -> Void in
                sourceDataTomorrow = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                
                // store tide levels for midnight til 24 hours from the current hour
                for var index = 0; index < hoursTomorrow; index++ {
                    next24HoursOfTides.append(sourceDataTomorrow![index]!["tide"]! as Int)
                }
                
                // store this new data into countyDataDictionary
                self.countyDataDictionary[county]!.tides = next24HoursOfTides
                
            })
            sourceTaskTomorrow.resume()
            
        })
        sourceTask.resume()
    }
    
    // getCountySwell takes a county and saves the county's current swells in
    func getCountySwell(county:String) {
        if (!contains(self.callLog[county]!, "CountySwell")) {
            self.callLog[county]!.append("CountySwell") // log this request
            
            // hoursTomorrow is the number of hours left between midnight tonight and 24 hours from the current hour
            // :: this is the number of hours we must store from the Spitcast data for tomorrow
            let hoursTomorrow:Int = self.currentHour
            
            // the array we will store the new data in before storing the array in the correct key in spotDataDictionary
            var newListOfSwells:[(height:Int, period:Int, direction:String)] = []
            
            // format the name of the county into the format Spitcast can understand
            let countyString:String = county.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
            
            let sourceURL:NSURL = NSURL(string: "http://api.spitcast.com/api/county/swell/\(countyString)/")!
            var sourceSession:NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            var sourceData:AnyObject? = nil
            let sourceTask = sourceSession.dataTaskWithURL(sourceURL, completionHandler: {(data, response, error) -> Void in
                sourceData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                
                // begin callback operation
                
                // Spitcast organizes the 6 possible sources of swell in keys "0", "1", ... , "5" in their JSON. Each key does not always have data,
                // so each key must be checked. If the key contains swell data, the data will be saved into countyDataDictionary
                for possibleKey in ["0", "1", "2", "3", "4", "5"] {
                    var directionInDegrees:Int? = sourceData![self.currentHour]![possibleKey]!!["dir"] as? Int
                    var heightInMeters:Float? = sourceData![self.currentHour]![possibleKey]!!["hs"] as? Float
                    var periodInSeconds:Float? = sourceData![self.currentHour]![possibleKey]!!["tp"] as? Float
                    
                    // if all data is present for this key, the data will be saved into a tuple, into countyDataDictionary
                    if directionInDegrees != nil && heightInMeters != nil && periodInSeconds != nil {
                        
                        // Spitcast responds with the data meters. Here, this value is converted into feet
                        var heightInFeet:Int = self.swellMetersToFeet(heightInMeters!)
                        
                        // degreesToDirection is used to convert the direction of a swell in degrees (270°)
                        var directionInHeading:String = self.degreesToDirection(directionInDegrees!)
                        
                        // periodAsInt converts the float value to an integer
                        var periodAsInt:Int = Int(periodInSeconds!)

                        // store the data into the temporary list
                        newListOfSwells += [(height:heightInFeet, period:periodAsInt, direction:directionInHeading)]
                    }
                }
                
                // store this data into countyDataDictionary
                self.countyDataDictionary[county]!.swells = newListOfSwells
            })
            sourceTask.resume()
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
            
            // add new key to the callLog for this county and intilialize it's value to an empty list (since no calls have been made for data for this county)
            self.callLog[countyName] = []
            
            // create a key for this county in countyDataDictionary
            self.countyDataDictionary[countyName] = (nil, nil, nil)
        }
    }
    
    // MARK: getting data for a spotID
    // name takes takes the id of a spot and returns the spot's name
    func name(id:Int) -> String { return self.spotDataDictionary[id]!.spotName }
    
    // county takes takes the id of a spot and returns the county the spot belongs to
    func county(id:Int) -> String { return self.spotDataDictionary[id]!.spotCounty }
    
    // currentHeight takes takes the id of a spot and returns the spot's forecasted swell height for the current hour
    // if swell data has been stored
    func currentHeight(id:Int) -> Int? { return self.spotDataDictionary[id]!.spotHeights?[0] }
    
    // MARK: getting data for a county
    // waterTemp takes the id of a spot and returns the current water temperature of the spot's county if the water temperature
    // has been stored for the county
    func waterTemp(id:Int) -> Int? { return self.countyDataDictionary[self.county(id)]!.waterTemp }
    
    // next24Tides takes the id of a spot and returns a list of the forecasted tide levels of the spot's county for the 
    // next 24 hours if tide data has been stored for the county
    func next24Tides(id:Int) -> [Int]? { return self.countyDataDictionary[self.county(id)]!.tides }
    
    // swells takes the id of a spot and returns a list of the swells currently affecting the spot's county if swell data 
    // has been stored for the county
    func swells(id:Int) -> [(height:Int, period:Int, direction:String)]? { return self.countyDataDictionary[self.county(id)]!.swells }
    
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
                self.spotDataDictionary[spotID] = (spotName, spotCounty, nil)
                
                // create all data entries for this county if one has not been made
                initializeCountyDataEntriesIfNeeded(spotCounty)
            }
        }
    }
    
    // MARK: math operations for spot and swell data
    // swellMetersToFeet takes a floating pointer number representing a distance in meters and returns an integer representing that distance in feet
    func swellMetersToFeet(height:Float) -> Int { return Int(height * 3.2) }
    
    // degreesToDirection takes a degree (0° ... 359°) and returns a string representing that degree as the abbreviation of a cardinal direction (NE, SW, S)
    func degreesToDirection(degrees:Int) -> String {
        if degrees == 0 || degrees == 360 {
            return "N"
        }
        else if degrees == 90 {
            return "E"
        }
        else if degrees == 180 {
            return "S"
        }
        else if degrees == 270 {
            return "W"
        }
        else if degrees > 0 && degrees < 90 {
            return "NE"
        }
        else if degrees > 90 && degrees < 180 {
            return "SE"
        }
        else if degrees > 180 && degrees < 270 {
            return "SW"
        }
        else if degrees > 270 && degrees < 360 {
            return "NW"
        }
        else {
            return " "
        }
    }
}



























