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
    @Binding var naturalSize: CGSize
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
            
//            guard let movieUrl = info[.mediaURL] as? URL else { return }
            guard let movieUrl = info[.mediaURL] as? URL else { return }

            let videoAsset = AVURLAsset(url : movieUrl)
            let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first!
            var naturalSize = videoAssetTrack.naturalSize.applying(videoAssetTrack.preferredTransform)
            let width = abs(naturalSize.width)
            let height = abs(naturalSize.height)
            naturalSize = CGSize(width: width, height: height)

            parent.selectedVideoURL = movieUrl
            parent.selectedVideo = AVPlayer(url: parent.selectedVideoURL!)
            parent.naturalSize = naturalSize

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
