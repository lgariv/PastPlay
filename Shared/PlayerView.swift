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

class PlayerUIView: UIView {
    @State var videoURL: URL?

    var playerLayer: AVPlayerLayer? = AVPlayerLayer()
    var player: AVPlayer? = AVPlayer(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)

    override init(frame: CGRect){
        super.init(frame: frame)
        guard let player = self.player else { return }
        player.play()
        playerLayer!.player = player
        layer.addSublayer(playerLayer!)
    }

    init?(videoURL: URL?, frame: CGRect) {
        super.init(frame: frame)
        self.videoURL = videoURL
        
        var player = AVPlayer()
        if let videoURL = self.videoURL {
            player = AVPlayer(url: videoURL)
        } else {
            player = AVPlayer(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
        }
        player.play()
        
        playerLayer!.player = player

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)

        layer.addSublayer(playerLayer!)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: .zero, completionHandler: nil)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer!.frame = bounds
    }
    
    func changeVideo(videoURL: URL?) {
        guard let player = self.player else { return }
        player.pause()
        self.player = nil

        if let OldPlayerLayer = self.playerLayer{
            OldPlayerLayer.removeFromSuperlayer()
            self.playerLayer = nil
        }

        self.layer.sublayers?.removeAll()

        self.playerLayer = AVPlayerLayer()
        guard let videoURL = videoURL else { return }
        self.player = AVPlayer(url: videoURL)
        self.player!.play()
        self.playerLayer!.player = player

        layer.addSublayer(self.playerLayer!)
    }
}

struct PlayerView: UIViewRepresentable {
    var player: AVPlayer?
    @Binding var videoURL: URL?
    let presentedView: PlayerUIView = PlayerUIView(frame: .zero)
    
    private var URLPlayer: AVPlayer {
        guard let player = player else {
            print("no::: player")
            guard let videoURL = videoURL else {
                print("no::: videoURL")
                return AVPlayer()
            }
            return AVPlayer(url: videoURL)
        }
        return player
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
        guard let videoURL = videoURL else { return }
        presentedView.changeVideo(videoURL: videoURL)
        print("should change")
    }

    func makeUIView(context: Context) -> UIView {
        print("should init")
        return self.presentedView
    }
}

//struct PlayerViewController: UIViewControllerRepresentable {
//    var player: AVPlayer?
//    @Binding var videoURL: URL?
//
//    let controller =  AVPlayerViewController()
//
//    private var URLPlayer: AVPlayer {
//        guard let player = player else {
//            guard let videoURL = videoURL else {
//                return AVPlayer()
//            }
//            return AVPlayer(url: videoURL)
//        }
//        return player
//    }
//
//    func makeUIViewController(context: Context) -> AVPlayerViewController {
//        controller.modalPresentationStyle = UIModalPresentationStyle.automatic
////        controller.showsPlaybackControls = false
//        controller.player = URLPlayer
////        controller.player?.play()
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
//        controller.player = URLPlayer
////        controller.player?.playImmediately(atRate: 1.0)
//        controller.player?.play()
//    }
//}

extension AVPlayer {
    var isVideoAvailable: Bool {
        return self.currentItem?.tracks.filter({$0.assetTrack!.mediaType == AVMediaType.video}).count != 0
    }
}
