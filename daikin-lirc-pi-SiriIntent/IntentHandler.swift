//
//  IntentHandler.swift
//  daikin-lirc-pi-SiriIntent
//
//  Created by Dang Duong Hung on 13/8/17.
//  Copyright © 2017 Dang Duong Hung. All rights reserved.
//

import Intents

class IntentHandler: INExtension, INStartWorkoutIntentHandling, INEndWorkoutIntentHandling {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    func handle(startWorkout intent: INStartWorkoutIntent, completion: @escaping (INStartWorkoutIntentResponse) -> Void) {
//        print("Start Workout Intent:", intent)
//        
//        let userActivity: NSUserActivity? = nil
//        guard let spokenPhrase = intent.workoutName?.spokenPhrase else {
//            completion(INStartWorkoutIntentResponse(code: .failureNoMatchingWorkout, userActivity: userActivity))
//            return
//        }
//        
//        print(spokenPhrase)
//        
//        completion(INStartWorkoutIntentResponse(code: .continueInApp, userActivity: userActivity))
        
        print("Starting Service")
        let activity = NSUserActivity(activityType: "start_service")
        let result = INStartWorkoutIntentResponse(code: .continueInApp, userActivity: activity)
        completion(result)
    }
    
    func handle(endWorkout intent: INEndWorkoutIntent, completion: @escaping (INEndWorkoutIntentResponse) -> Void) {
        print("Ending Service")
        let result = INEndWorkoutIntentResponse(code: .continueInApp, userActivity: nil)
        completion(result)
    }
    
//    func resolveWorkoutName(forStartWorkout intent: INStartWorkoutIntent, with completion: @escaping (INSpeakableStringResolutionResult) -> Void) {
//        
//    }
    
    
    
}

