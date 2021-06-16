//
//  ContentView.swift
//  Shared
//
//  Created by Lavie Gariv on 12/06/2021.
//

import SwiftUI
import AVKit
import VideoPlayerView

struct ContentView: View {
    
    @State private var isShowPhotoLibrary = false
    @State private var shouldShowIdentificationResult = false
    @State private var video = AVPlayer()
    @State private var videoURL = URL(string: "https://")
    @State private var begin = false
    @State private var finished = false
    @State private var videoExists = false

    @StateObject private var matcher = Matcher()
    @State private var matchFound = false

    @State private var play: Bool = true
    @State private var time: CMTime = .zero

    @State private var videoSize: CGSize = UIScreen.main.bounds.size

    var body: some View {
        ZStack {
            Text("Please choose a video to start.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            NewVideoPlayer(url: self.videoURL, play: $play, time: $time)
                .autoReplay(true)
                .aspectRatio(CGSize(width: videoSize.width, height: videoSize.height), contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .onChange(of: videoURL) { newVideo in
                    if newVideo?.absoluteString != "https://" {
                        print("videoSize:: \(self.videoSize)")
                    }
                }
            VStack {
                if videoURL == nil || videoURL?.absoluteString == "https://" {} else {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            video = AVPlayer()
                            videoURL = URL(string: "https://")
                            videoExists = false
                            print("Video Exist:: false")
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 24))
                                .padding(.all)
                        }
                    }
                }
                
                Spacer()

                Button(action: {
                    if videoURL == nil || videoURL?.absoluteString == "https://" {
                        self.isShowPhotoLibrary = true
                    } else {
                        self.shouldShowIdentificationResult = true
                    }
                }) {
                    HStack {
                        if videoURL == nil || videoURL?.absoluteString == "https://" {
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
            .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: UIScreen.main.bounds.size.height, alignment: .center)
            .layoutPriority(1)
        }
        .onChange(of: videoURL) { newVideo in
            guard let newVideo = newVideo else { return }
            if newVideo.absoluteString != "https://" {
                videoExists = true
                print("Video Exist:: true")
            } else {
                videoExists = false
                print("Video Exist:: false")
            }
        }
        .onChange(of: shouldShowIdentificationResult) { newValue in
            guard newValue == true else { return }
            self.matcher.lookForMatch(videoURL: videoURL!)
        }
        .onChange(of: matcher.result) { newResult in
            guard newResult != nil else {
                print("found no match")
                return
            }
            print("found match")
            self.matchFound = true
        }
        .sheet(isPresented: $isShowPhotoLibrary) {
            VideoPicker(selectedVideo: $video, selectedVideoURL: $videoURL, naturalSize: $videoSize, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $shouldShowIdentificationResult) {
            IdentificationResult(matchFound: $matchFound)
                .environmentObject(self.matcher)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
