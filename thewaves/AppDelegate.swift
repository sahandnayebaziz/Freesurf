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
    
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let vc = self.window!.rootViewController!.childViewControllers[0] as YourSpotsTableViewController
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(vc.spotLibrary.exportLibraryToString(), forKey: "userSelectedSpots")
        defaults.setObject(NSDate().hoursAfterDate(NSDate(fromString: "13 July 1993", format: .Custom("dd MMM yyyy"))), forKey: "hoursMarker")
        defaults.synchronize()
    }
    
    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        let vc = self.window!.rootViewController!.childViewControllers[0] as YourSpotsTableViewController
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let hoursStored = defaults.objectForKey("hoursMarker") as? Int {
            let currentHours:Int = NSDate().hoursAfterDate(NSDate(fromString: "13 July 1993", format: .Custom("dd MMM yyyy")))
            if currentHours > hoursStored {
                NSLog("need to refresh")
                if let exportString = defaults.objectForKey("userSelectedSpots") as? String {
                    vc.usingUserDefaults = true
                    vc.spotLibrary = SpotLibrary()
                    vc.spotLibrary.initLibraryFromString(exportString)
                    vc.viewWillAppear(false)
                }
            }
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

