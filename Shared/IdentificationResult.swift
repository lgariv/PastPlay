//
//  IdentificationResult.swift
//  PastPlay
//
//  Created by Lavie Gariv on 13/06/2021.
//

import SwiftUI
import AVKit
import ShazamKit
import MusicKit

class Matcher: NSObject, ObservableObject, SHSessionDelegate {
    @Published var result: SHMatch? = nil

    private var audioEngine = AVAudioEngine()
    
    private lazy var session = SHSession()
    private lazy var signature = SHSignature()

    func getMatch(videoURL: URL) -> Void {
        session.match(signature)
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
    
    func lookForMatch(videoURL: URL) -> Void {
        // The session is what we use to recognize what's playing.
        session = SHSession()
        // The delegate will receive callbacks when the media is recognized.
        session.delegate = self
        
        let signatureGenerator = SHSignatureGenerator()
        
        let asset = AVURLAsset(url: videoURL)
        let reader = try! AVAssetReader(asset: asset)
        let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first
        let audioReadSetting: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM]
        let output = AVAssetReaderTrackOutput(track: audioAssetTrack!, outputSettings: audioReadSetting)
        if reader.canAdd(output) { reader.add(output) }
        
        reader.startReading()

        var totalBufferDuration = TimeInterval(0)
        while let audioBuffer = output.copyNextSampleBuffer() {
            let buffer = convertBuffer(sampleBuffer: audioBuffer)
            var bufferDuration: TimeInterval {
                let framecount = Double(buffer.frameLength)
                let samplerate = buffer.format.sampleRate
                print("time is : \(totalBufferDuration)")
                return TimeInterval(framecount / samplerate)
            }
            totalBufferDuration = totalBufferDuration + bufferDuration
            if totalBufferDuration >= 12.0 { break } else {
                try? signatureGenerator.append(buffer, at: nil)
            }
        }

        signature = signatureGenerator.signature()
        session.match(signature)

//        print("matching session: \(session)")
//        print("matching audioAssetTrack: \(audioAssetTrack)")
//        print("matching reader: \(reader)")
//        print("matching output: \(output)")
////        print("matching audioBuffer: \(String(describing: audioBuffer))")
////        print("matching buffer: \(buffer)")
//        print("matching signatureGenerator: \(signatureGenerator)")
//        print("matching signature: \(signature)")
    }

    func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.async {
            self.result = match
            print("match: \(match.mediaItems.first!.songs.first!.artistName)")
        }
    }
    
    func session(_ session: SHSession,
       didNotFindMatchFor signature: SHSignature,
                 error: Error?) {
        DispatchQueue.main.async {
            print("match error: \(String(describing: error))")
        }
    }
}

struct IdentificationResult: View {
    @Binding var matchFound: Bool
    @EnvironmentObject var matcher: Matcher
    
    var body: some View {
        if let Match = matcher.result?.mediaItems.first {
            ArtworkImage(Match.songs.first!.artwork!, width: Int(UIScreen.main.bounds.size.width))
                .aspectRatio(contentMode: .fit)
                .padding()
                .cornerRadius(8)
            HStack {
                VStack(alignment: .leading) {
                    Text("\(Match.songs.first!.title)")
                        .font(.title)
                        .bold()
                    Text("\(Match.songs.first!.artistName)")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    SHMediaLibrary.default.add([Match]) {error in
                        if error != nil {
                            // handle the error
                        }
                    }
                }, label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                })
            }
            .padding(.horizontal)
            
            Spacer()
        } else {
            Image(systemName: "photo.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
                .cornerRadius(8)
            HStack {
                VStack(alignment: .leading) {
                    Text("No Song Detected")
                        .font(.title)
                        .bold()
                    Text("Artist")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

//struct IdentificationResult_Previews: PreviewProvider {
//    static var previews: some View {
//        IdentificationResult(matchFound: $fakeMatchFound)
//    }
//}
