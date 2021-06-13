//
//  PastPlayApp.swift
//  Shared
//
//  Created by Lavie Gariv on 12/06/2021.
//

import SwiftUI
import AVFoundation

@main
struct PastPlayApp: App {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        return true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
