//
//  AppDelegate.swift
//  Burro
//
//  Created by Evan Heidtmann on 1/30/20.
//  Copyright © 2020 Evan Heidtmann. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Combine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    var tvd: TrackingViewData?
    var trackingStateCancellable : AnyCancellable?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        locationManager.desiredAccuracy = 10
        locationManager.delegate = self
        locationManager.activityType = CLActivityType.other
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        
        if TrackingState.getFromUserDefaults().shouldTrackLocations() {
            locationManager.startUpdatingLocation()
        }
        
        return true
    }
    
    func onTrackingStateChange(_ ts: TrackingState) {
        if ts.shouldTrackLocations() {
            print("startUpdatingLocation")
            locationManager.startUpdatingLocation() // idempotent
        }
        else {
            print("stopUpdatingLocation")
            locationManager.stopUpdatingLocation()
        }
    }
    
    func hasGoodGPSFix() -> Bool {
        if let loc = lastLocation {
            let dateOk = abs(loc.timestamp.distance(to: Date())) < 10
            let accuracyOk = loc.horizontalAccuracy <= 30
            return dateOk && accuracyOk
        }
        return false
    }
    
    func linkToTVD(_ trackingViewData: TrackingViewData) {
        tvd = trackingViewData
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
        if let location = lastLocation {
            print("Got location: ", location)
            uploadLocation(location)
        }
        if let trackingViewData = tvd {
            trackingViewData.haveGoodGPSFix = self.hasGoodGPSFix()
            // TODO: figure out how to update this on a timer in case we stop getting locations
        }
    }
    
    func uploadLocation(_ location: CLLocation) {
        let endpoint = "https://enh06upo7jwzf.x.pipedream.net"
        guard let url = URL(string: endpoint) else {
            print("Failed to make url: \(endpoint)")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let dateFormatter = ISO8601DateFormatter.init()
        do {
            let locationDict = [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "horizontalAccuracy": location.horizontalAccuracy,
                "date": dateFormatter.string(from: location.timestamp),
                ] as [String : Any]
            let jsonStr = try JSONSerialization.data(withJSONObject: locationDict, options: [])
            request.httpBody = jsonStr
        }
        catch {
            print("Can't write JSON object for location")
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { _, _, _ in })
        task.resume()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Burro")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

