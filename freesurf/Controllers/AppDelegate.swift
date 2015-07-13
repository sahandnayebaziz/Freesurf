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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {
//        let splitViewController = self.window!.rootViewController as! UISplitViewController
//        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
//        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
//        splitViewController.delegate = self
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // When Freesurf enters the background, the date and time are recorded to the NSUserDefaults for comparison the next time the user accesses Freesurf.
        // If the user is accessing Freesurf from the background in the same hour on the same day as they last did, nothing is done. If it is a new hour, the tableview is reloaded. If it is a new day, the Spitcast data is refreshed.
        let viewController = self.window!.rootViewController!.childViewControllers[0] as! SpotsTableViewController
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        // A serialized SpotLibrary object is saved to NSUserDefaults
        defaults.setObject(viewController.spotLibrary.serializeSpotLibraryToString(), forKey: "userSelectedSpots")
        
        // A date and time string is saved to NSUserDefaults
        defaults.setObject(NSDate().toString(format: .Custom("dd MMM yyyy")), forKey: "dateOfLastOpen")
        defaults.setObject(NSDate().toString(format: .Custom("HH")), forKey: "hourOfLastOpen")
        
        // NSUserDefaults is updated manually with the new values
        defaults.synchronize()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // Compare the hour and date of the last time Freesurf was accessed and refresh any old data
        let viewController = self.window!.rootViewController!.childViewControllers[0] as! SpotsTableViewController
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if let dateOfLastOpen:String = defaults.objectForKey("dateOfLastOpen") as? String {
            let currentDate = NSDate().toString(format: .Custom("dd MMM yyyy"))
            if currentDate != dateOfLastOpen {
                if let exportString = defaults.objectForKey("userSelectedSpots") as? String {
                    viewController.usingUserDefaults = true
                    viewController.spotLibrary = SpotLibrary(serializedSpotLibrary: exportString)
                    viewController.viewWillAppear(false)
                }
            }
        }
        
        if let hourOfLastOpen = defaults.objectForKey("hourOfLastOpen") as? String {
            let currentHour = NSDate().toString(format: .Custom("HH"))
            if currentHour != hourOfLastOpen {
                viewController.spotsTableView.reloadData()
            }
        }
        
        // for legacy users updating to Freesurf v1.0.3 with an older NSUserDefaults
        if let legacyHoursString = defaults.objectForKey("hoursMarker") as? String {
            if let exportString = defaults.objectForKey("userSelectedSpots") as? String {
                viewController.usingUserDefaults = true
                viewController.spotLibrary = SpotLibrary(serializedSpotLibrary: exportString)
                viewController.viewWillAppear(false)
            }
            defaults.removeObjectForKey("hoursMarker")
            defaults.synchronize()
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

