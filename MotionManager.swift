//
//  MotionManager.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/10/25.
//
import CoreMotion

class MotionManager: ObservableObject {
    private let activityManager = CMMotionActivityManager()
    @Published var activity: String = "Unknown"
    
    init() {
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: .main) { [weak self] activity in
                guard let activity = activity else { return }
                // Add debug print below:
                print("Activity detected:", activity)
                DispatchQueue.main.async {
                    if activity.walking {
                        self?.activity = "Walking"
                    } else if activity.automotive {
                        self?.activity = "Driving"
                    } else if activity.stationary {
                        self?.activity = "Stationary"
                    } else {
                        self?.activity = "Unknown"
                    }
                }
            }
        }
    }
}
