//
//  PlayerView.swift
//  PastPlay
//
//  Created by Lavie Gariv on 13/06/2021.
//

import SwiftUI
import UIKit
import AVKit

extension AVPlayerViewController: AVPlayerViewControllerDelegate {
    @objc func playerItemDidReachEnd(notification: Notification) {
        print("playerItemDidReachEnd")
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        }
    }
}

struct PlayerViewController: UIViewControllerRepresentable {
    var player: AVPlayer?
    var videoURL: URL?
    
    let controller =  AVPlayerViewController()
    
    private var URLPlayer: AVPlayer {
        guard let player = player else {
            guard let videoURL = videoURL else {
                return AVPlayer()
            }
            return AVPlayer(url: videoURL)
        }
        return player
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        controller.modalPresentationStyle = .fullScreen
        controller.showsPlaybackControls = false
        controller.player = URLPlayer
        controller.player?.play()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        controller.player = URLPlayer
        controller.player?.play()
    }
}

extension AVPlayer {
    var isVideoAvailable: Bool {
        return self.currentItem?.tracks.filter({$0.assetTrack!.mediaType == AVMediaType.video}).count != 0
    }
}
