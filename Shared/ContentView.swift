//
//  ContentView.swift
//  Shared
//
//  Created by Lavie Gariv on 12/06/2021.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    @State private var isShowPhotoLibrary = false
    @State private var shouldShowIdentificationResult = false
    @State private var video = AVPlayer()
    @State private var videoURL = URL(string: "")
    @State private var begin = false
    @State private var finished = false
    @State private var videoExists = false

    @StateObject private var detector = Detector()

    var body: some View {
        ZStack {
//            PlayerViewController(player: self.video)
            PlayerViewController(videoURL: self.videoURL)
                .onAppear() {
                    // Start the player going, otherwise controls don't appear
                    videoExists = true
                    video.play()
                }
                .onDisappear() {
                    // Stop the player when the view disappears
//                    videoExists = false
                    video.pause()
                }
//                .opacity(videoExists ? 1 : 0)
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)

            VStack {
                if videoURL == nil || videoURL?.absoluteString == "" {} else {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            video = AVPlayer()
                            videoURL = URL(string: "")
                            videoExists = false
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 24))
                                .padding(.all)
                        }
                    }
                }
                
                Spacer()

                Button(action: {
                    if videoURL == nil || videoURL?.absoluteString == "" {
                        self.isShowPhotoLibrary = true
                    } else {
                        self.shouldShowIdentificationResult = true
                    }
                }) {
                    HStack {
                        if videoURL == nil || videoURL?.absoluteString == "" {
                            Image(systemName: "video.fill")
                                .font(.system(size: 20))
                            
                            Text("Choose a Video")
                                .font(.headline)
                        } else {
                            Image(systemName: "music.note")
                                .font(.system(size: 20))

                            Text("Identify Song")
                                .font(.headline)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.all)
            }
            }
        }
        .onChange(of: videoURL) { newValue in
            guard let videoURL = newValue else {
                print("no URL")
                return
            }
            self.detector.lookForMatch(videoURL: videoURL)
        }
        .sheet(isPresented: $isShowPhotoLibrary) {
            VideoPicker(selectedVideo: $video, selectedVideoURL: $videoURL, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $shouldShowIdentificationResult) {
//            IdentificationResult(detector: self.detector)
            IdentificationResult()
                .environmentObject(self.detector)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
