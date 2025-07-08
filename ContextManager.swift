//
//  ContextManager.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/11/25.
//
import Foundation
import CoreLocation
import Combine

class ContextManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var detectedStoreID: UUID? = nil
    @Published var currentContext: String = "Unknown"

    private let locationManager = CLLocationManager()
    private var monitoredRegions: [UUID: CLCircularRegion] = [:]
    private var cancellables = Set<AnyCancellable>()
    private var appData: AppData

    init(appData: AppData) {
        self.appData = appData
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true

        // Observe changes to stores and refresh geofences
        appData.$stores
            .sink { [weak self] _ in
                self?.refreshGeofences()
            }
            .store(in: &cancellables)

        refreshGeofences()
    }

    func refreshGeofences() {
        // Remove old regions
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        monitoredRegions.removeAll()

        // Set up geofences for each store
        for store in appData.stores {
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude),
                radius: store.radius,
                identifier: store.id.uuidString
            )
            region.notifyOnEntry = true
            region.notifyOnExit = false
            locationManager.startMonitoring(for: region)
            locationManager.requestState(for: region)  // <--- NEW: detect if user is already inside
            monitoredRegions[store.id] = region
        }
    }

    // CLLocationManagerDelegate methods

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let uuid = UUID(uuidString: region.identifier) {
            print("Entered region for store id: \(uuid)")
            DispatchQueue.main.async {
                self.detectedStoreID = uuid
                self.currentContext = "At store"
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let uuid = UUID(uuidString: region.identifier) {
            print("Exited region for store id: \(uuid)")
            DispatchQueue.main.async {
                if self.detectedStoreID == uuid {
                    self.detectedStoreID = nil
                    self.currentContext = "Unknown"
                }
            }
        }
    }

    // <--- NEW: Handles "already inside" regions
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard let uuid = UUID(uuidString: region.identifier) else { return }
        if state == .inside {
            print("Already inside region for store id: \(uuid)")
            DispatchQueue.main.async {
                self.detectedStoreID = uuid
                self.currentContext = "At store"
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location authorization changed: \(status.rawValue)")
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            refreshGeofences()
        }
    }
}
