//
//  ContextManager.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/11/25.
//

//
//  ContextManager.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/11/25.

import Foundation
import CoreLocation
import Combine
import UserNotifications

class ContextManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var detectedStore: String? = nil
    @Published var currentContext: String = "Unknown"
    
    private let locationManager = CLLocationManager()
    
    // Define your store geofences: [storeName: (lat, lon, radius)]
    let stores: [String: (Double, Double, Double)] = [
        "Trader Joe's": (37.3374506571522, -122.06723610356782, 150),
        "Lucky": (37.34227296639594, -122.07110998921009, 150),
        "Walmart": (37.401147917393466, -122.10886187942062, 150),
        "Costco": (37.372610899382046, -121.99305182644429, 150)
        
        // Add more stores as needed
    ]
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true

        // 1. Check if region monitoring is available
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            print("Region monitoring IS available!")
        } else {
            print("Region monitoring NOT available.")
        }
        
        setupGeofences()

        // 2. List all monitored regions right after setup
        for region in locationManager.monitoredRegions {
            print("Currently monitoring: \(region.identifier)")
        }
    }
    
    func setupGeofences() {
        for (store, (lat, lon, radius)) in stores {
            print("Setting up geofence for \(store) at \(lat),\(lon) radius \(radius)")
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let region = CLCircularRegion(center: center, radius: radius, identifier: store)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            locationManager.startMonitoring(for: region)
            locationManager.requestState(for: region)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region: \(region.identifier) at \(Date())")
        DispatchQueue.main.async {
            self.detectedStore = region.identifier
            self.currentContext = "At \(region.identifier)"
        }
        // Schedule local notification
        sendArrivalNotification(for: region.identifier)
    }
    
    func sendArrivalNotification(for store: String) {
        let content = UNMutableNotificationContent()
        content.title = "Grocery List Reminder"
        content.body = "You’ve arrived at \(store)! Tap to hear your list."
        content.sound = .default

        // Immediate trigger
        let request = UNNotificationRequest(identifier: "arrival-\(store)-\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region: \(region.identifier) at \(Date())")
        DispatchQueue.main.async {
            if self.detectedStore == region.identifier {
                self.detectedStore = nil
                self.currentContext = "Unknown"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            print("Already inside region: \(region.identifier)")
            DispatchQueue.main.async {
                self.detectedStore = region.identifier
                self.currentContext = "At \(region.identifier)"
            }
        } else if state == .outside {
            print("Outside region: \(region.identifier)")
        } else {
            print("Region state unknown for: \(region.identifier)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location authorization changed: \(status.rawValue)")
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            setupGeofences()
        }
    }
    
    // Region monitoring error delegate
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region \(region?.identifier ?? "unknown"): \(error.localizedDescription)")
    }
}
