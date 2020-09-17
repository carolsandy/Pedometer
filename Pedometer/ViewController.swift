//
//  ViewController.swift
//  Pedometer
//
//  Created by Carmen Salvador on 16/09/20.
//  Copyright © 2020 Carmen Salvador. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private var shouldStartUpdating: Bool = false
    private var startDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func startStop(_ sender: Any) {
        shouldStartUpdating = !shouldStartUpdating
        shouldStartUpdating ? onStart() : onStop()
    }
    
    private func onStart() {
        startDate = Date()
        checkAuthorizationStatus()
        startUpdating()
    }
    
    private func onStop() {
        startDate = nil
        stopUpdating()
    }
    
    private func checkAuthorizationStatus() {
        switch CMMotionActivityManager.authorizationStatus() {
        case CMAuthorizationStatus.denied:
            onStop()
            activityLabel.text = "Not available"
            stepsLabel.text = "Not available"
        default:
            break
        }
    }
    
    private func startUpdating() {
        if CMMotionActivityManager.isActivityAvailable() {
            startTrackingActivity()
        } else {
            activityLabel.text = "Not available"
        }
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        } else {
            stepsLabel.text = "Not available"
        }
    }
    
    private func stopUpdating() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        pedometer.stopEventUpdates()
    }
    
    private func startTrackingActivity() {
        activityManager.startActivityUpdates(to: OperationQueue.main) { [weak self] (activity: CMMotionActivity?) in
            guard let activity = activity else { return }
            DispatchQueue.main.async {
                if activity.walking {
                    self?.activityLabel.text = "Activity: Walking"
                } else if activity.stationary {
                    self?.activityLabel.text = "Activity: Stationary"
                } else if activity.running {
                    self?.activityLabel.text = "Activity: Running"
                } else if activity.automotive {
                    self?.activityLabel.text = "Activity: Automotive"
                }
            }
        }
    }
    
    private func startCountingSteps() {
        pedometer.startUpdates(from: Date()) { [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            DispatchQueue.main.async {
                self?.stepsLabel.text = "Steps: \(pedometerData.numberOfSteps.stringValue)"
            }
        }
    }
    
}

