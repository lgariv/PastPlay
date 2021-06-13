//
//  IdentificationResult.swift
//  PastPlay
//
//  Created by Lavie Gariv on 13/06/2021.
//

import SwiftUI
import AVKit
import ShazamKit

class Detector: NSObject, ObservableObject, SHSessionDelegate {
    @Published var result: SHMatch? = nil

    private var audioEngine = AVAudioEngine()
    
    private lazy var session = SHSession()
    
    func getMatch(videoURL: URL) -> Void {
    }
    
    func convertBuffer(sampleBuffer: CMSampleBuffer) -> AVAudioPCMBuffer {
        var asbd = CMSampleBufferGetFormatDescription(sampleBuffer)!.audioStreamBasicDescription!
        var audioBufferList = AudioBufferList()
        var blockBuffer : CMBlockBuffer?
        
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: nil,
            bufferListOut: &audioBufferList,
            bufferListSize: MemoryLayout<AudioBufferList>.size,
            blockBufferAllocator: nil,
            blockBufferMemoryAllocator: nil,
            flags: 0,
            blockBufferOut: &blockBuffer
        )
        
        let mBuffers = audioBufferList.mBuffers
        let frameLength = AVAudioFrameCount(Int(mBuffers.mDataByteSize) / MemoryLayout<Float>.size)
        let pcmBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(streamDescription: &asbd)!, frameCapacity: frameLength)!
        pcmBuffer.frameLength = frameLength
        pcmBuffer.mutableAudioBufferList.pointee.mBuffers = mBuffers
        pcmBuffer.mutableAudioBufferList.pointee.mNumberBuffers = 1
        
        return pcmBuffer
    }
    
    func lookForMatch(videoURL: URL) {
        // The session is what we use to recognize what's playing.
        session = SHSession()
        // The delegate will receive callbacks when the media is recognized.
        session.delegate = self
        
        let signatureGenerator = SHSignatureGenerator()
        
        let asset = AVURLAsset(url: videoURL)
        guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else {
            print("audioAssetTrack")
            return
        }
        guard let reader = try? AVAssetReader(asset: asset) else {
            print("reader")
            return
        }
        let audioReadSetting: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM]
        guard let output = try? AVAssetReaderTrackOutput(track: audioAssetTrack, outputSettings: audioReadSetting) else {
            print("output")
            return
        }
        if reader.canAdd(output) {
            print("canAdd(\(output))")
            reader.add(output)
        }
        reader.startReading()
        let audioBuffer = output.copyNextSampleBuffer()
        let buffer = convertBuffer(sampleBuffer: audioBuffer!)
        
        try? signatureGenerator.append(buffer, at: nil)
        let signature = signatureGenerator.signature()
        
        session.match(signature)
        
        print("matching session: \(session)")
        print("matching audioAssetTrack: \(audioAssetTrack)")
        print("matching reader: \(reader)")
        print("matching output: \(output)")
        print("matching audioBuffer: \(String(describing: audioBuffer))")
        print("matching buffer: \(buffer)")
        print("matching signatureGenerator: \(signatureGenerator)")
        print("matching signature: \(signature)")
    }

    func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.async {
            self.result = match
            print("match: \(match.mediaItems.first!.songs.first!.artistName)")
        }
    }
}

struct IdentificationResult: View {
    @State var match: SHMatch?
    @EnvironmentObject var detector: Detector
    
    var body: some View {
        if let result = detector.result {
            Text("\(result.mediaItems.first!.songs.first!.artistName)")
                .onAppear(perform: {
                    match = detector.result
                })
        } else {
            Text("Hello, World!")
                .onAppear(perform: {
                    match = detector.result
                })
        }
    }
}

//struct IdentificationResult_Previews: PreviewProvider {
//    static var previews: some View {
//        IdentificationResult()
//    }
//}
