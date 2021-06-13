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

    var body: some View {
        ZStack {
            PlayerViewController(player: self.video)
//            PlayerViewController(videoURL: self.videoURL)
                .onAppear() {
                    // Start the player going, otherwise controls don't appear
                    video.play()
                }
                .onDisappear() {
                    // Stop the player when the view disappears
                    video.pause()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                if videoURL == nil || videoURL?.absoluteString == "" {} else {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            video = AVPlayer()
                            videoURL = URL(string: "")
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
        .sheet(isPresented: $isShowPhotoLibrary) {
            VideoPicker(selectedVideo: $video, selectedVideoURL: $videoURL, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $shouldShowIdentificationResult) {
            IdentificationResult()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
