//
//  AppDelegate.swift
//  thewaves
//
//  Created by Sahand Nayebaziz on 8/2/14.
//  Copyright (c) 2014 Sahand Nayebaziz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var sharedDefaults = NSUserDefaults(suiteName: "group.freesurf")
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        if NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys.contains("userSelectedSpots") {
            
            let oldDefaults = NSUserDefaults.standardUserDefaults()
            let savedSpots = oldDefaults.objectForKey("userSelectedSpots") as? String
            let dateOpened = oldDefaults.objectForKey("dateOfLastOpen") as? String
            let hourOpened = oldDefaults.objectForKey("hourOfLastOpen") as? String
            
            let newDefaults = sharedDefaults
            if newDefaults != nil {
                newDefaults!.setObject(savedSpots, forKey: "userSelectedSpots")
                newDefaults!.setObject(dateOpened, forKey: "dateOfLastOpen")
                newDefaults!.setObject(hourOpened, forKey: "hourOfLastOpen")
                
                oldDefaults.removeObjectForKey("userSelectedSpots")
                oldDefaults.removeObjectForKey("dateOfLastOpen")
                oldDefaults.removeObjectForKey("hourOfLastOpen")
                print("copied old defaults to new defaults")
            }
            
            
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        if let defaults = sharedDefaults {
            defaults.setObject(NSDate().toString(format: .Custom("dd MMM yyyy")), forKey: "dateOfLastOpen")
            defaults.setObject(NSDate().toString(format: .Custom("HH")), forKey: "hourOfLastOpen")
            defaults.synchronize()
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // Compare the hour and date of the last time Freesurf was accessed and refresh any old data
        let splitVC = self.window!.rootViewController as! UISplitViewController
        let tableVC = (splitVC.viewControllers[0] as! UINavigationController).topViewController as! SpotsTableViewController
        
        if let defaults = sharedDefaults {
            if let dateOfLastOpen:String = defaults.objectForKey("dateOfLastOpen") as? String {
                let currentDate = NSDate().toString(format: .Custom("dd MMM yyyy"))
                if currentDate != dateOfLastOpen {
                    if let exportString = defaults.objectForKey("userSelectedSpots") as? String {
                        tableVC.usingUserDefaults = true
                        tableVC.spotLibrary = SpotLibrary(serializedSpotLibrary: exportString)
                        tableVC.viewWillAppear(false)
                    }
                }
            }
            
            if let hourOfLastOpen = defaults.objectForKey("hourOfLastOpen") as? String {
                let currentHour = NSDate().toString(format: .Custom("HH"))
                if currentHour != hourOfLastOpen {
                    tableVC.spotsTableView.reloadData()
                }
            }
            
            // for legacy users updating to Freesurf v1.0.3 with an older NSUserDefaults
            if let _ = defaults.objectForKey("hoursMarker") as? String {
                if let exportString = defaults.objectForKey("userSelectedSpots") as? String {
                    tableVC.usingUserDefaults = true
                    tableVC.spotLibrary = SpotLibrary(serializedSpotLibrary: exportString)
                    tableVC.viewWillAppear(false)
                }
                defaults.removeObjectForKey("hoursMarker")
                defaults.synchronize()
            }
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

