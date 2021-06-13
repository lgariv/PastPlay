//
//  VideoPicker.swift
//  PastPlay
//
//  Created by Lavie Gariv on 13/06/2021.
//

import UIKit
import SwiftUI
import MobileCoreServices
import AVKit

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var selectedVideo: AVPlayer
    @Binding var selectedVideoURL: URL?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeUIViewController(context: UIViewControllerRepresentableContext<VideoPicker>) -> UIImagePickerController {
        
        let videoPicker = UIImagePickerController()
        videoPicker.allowsEditing = false
        videoPicker.sourceType = sourceType
        videoPicker.mediaTypes = [kUTTypeMovie as String]
        videoPicker.delegate = context.coordinator
        
        return videoPicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<VideoPicker>) {
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            guard let movieUrl = info[.mediaURL] as? URL else { return }
            parent.selectedVideoURL = movieUrl
            parent.selectedVideo = AVPlayer(url: parent.selectedVideoURL!)

//            let composition = AVMutableComposition()
//            do {
//                let asset = AVURLAsset(url: movieUrl)
//                guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return }
//                guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
//                try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
//            } catch {
//                print(error)
//            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
