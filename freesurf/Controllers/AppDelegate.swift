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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
//        MyFirstViewController* firstVC = [[MyFirstViewController alloc] init];
//        MySecondViewController* secondVC = [[MySecondViewController alloc] init];
//        
//        UISplitViewController* splitVC = [[UISplitViewController alloc] init];
//        splitVC.viewControllers = [NSArray arrayWithObjects:firstVC, secondVC, nil];
//        
//        window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        window.rootViewController = splitVC;
//        [window makeKeyAndVisible];
//        
//        return YES;
        let master = SpotsViewController()
        let masterNav = UINavigationController(rootViewController: master)
        
        let detail = DetailViewController(nibName: nil, bundle: nil)
        let detailNav = UINavigationController(rootViewController: detail)
        
        let splitView = UISplitViewController()
        splitView.viewControllers = [masterNav, detailNav]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.backgroundColor = UIColor.white
            window.rootViewController = splitView
            window.makeKeyAndVisible()
        }

        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        
//        // When Freesurf enters the background, the date and time are recorded to the NSUserDefaults for comparison the next time the user accesses Freesurf.
//        // If the user is accessing Freesurf from the background in the same hour on the same day as they last did, nothing is done. If it is a new hour, the tableview is reloaded. If it is a new day, the Spitcast data is refreshed.
//        let splitVC = self.window!.rootViewController as! UISplitViewController
//        let tableVC = (splitVC.viewControllers[0] as! UINavigationController).topViewController as! SpotsTableViewController
//        let defaults:UserDefaults = UserDefaults.standard
//        
//        // A serialized SpotLibrary object is saved to NSUserDefaults
//        defaults.set(tableVC.spotLibrary.serializeSpotLibraryToString(), forKey: "userSelectedSpots")
//        
//        // A date and time string is saved to NSUserDefaults
//        defaults.setObject(Date().toString(format: .Custom("dd MMM yyyy")), forKey: "dateOfLastOpen")
//        defaults.setObject(Date().toString(format: .Custom("HH")), forKey: "hourOfLastOpen")
//        
//        // NSUserDefaults is updated manually with the new values
//        defaults.synchronize()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
//        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//        
//        // Compare the hour and date of the last time Freesurf was accessed and refresh any old data
//        let splitVC = self.window!.rootViewController as! UISplitViewController
//        let tableVC = (splitVC.viewControllers[0] as! UINavigationController).topViewController as! SpotsTableViewController
//        let defaults:UserDefaults = UserDefaults.standard
//        
//        if let dateOfLastOpen:String = defaults.object(forKey: "dateOfLastOpen") as? String {
//            let currentDate = Date().toString(format: .Custom("dd MMM yyyy"))
//            if currentDate != dateOfLastOpen {
//                if let exportString = defaults.object(forKey: "userSelectedSpots") as? String {
//                    tableVC.usingUserDefaults = true
//                    tableVC.spotLibrary = SpotLibrary(serializedSpotLibrary: exportString)
//                    tableVC.viewWillAppear(false)
//                }
//            }
//        }
//        
//        if let hourOfLastOpen = defaults.object(forKey: "hourOfLastOpen") as? String {
//            let currentHour = Date().toString(format: .Custom("HH"))
//            if currentHour != hourOfLastOpen {
//                tableVC.spotsTableView.reloadData()
//            }
//        }
//        
//        // for legacy users updating to Freesurf v1.0.3 with an older NSUserDefaults
//        if let _ = defaults.object(forKey: "hoursMarker") as? String {
//            if let exportString = defaults.object(forKey: "userSelectedSpots") as? String {
//                tableVC.usingUserDefaults = true
//                tableVC.spotLibrary = SpotLibrary(serializedSpotLibrary: exportString)
//                tableVC.viewWillAppear(false)
//            }
//            defaults.removeObject(forKey: "hoursMarker")
//            defaults.synchronize()
//        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

