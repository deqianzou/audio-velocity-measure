//
//  PlaySineWave.swift
//  project
//
//  Created by JTDX on 2017/6/19.
//  Copyright © 2017年 texot. All rights reserved.
//


import Foundation
import AVFoundation

class PlaySineWave{
    var audioEngine = AVAudioEngine()
    var audioFormat : AVAudioFormat
    let FL: AVAudioFrameCount = 44100
    let freq : Float = 19000 //19kHz
    
    var pcmBuffer : AVAudioPCMBuffer
    
    init()  {
        self.audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)
        self.pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat,
                                          frameCapacity:AVAudioFrameCount(FL))
        self.pcmBuffer.frameLength = AVAudioFrameCount(FL)
    }
    
    func play(){
        let floatData = self.pcmBuffer.floatChannelData!.pointee
        let step = 2 * Float.pi/Float(FL)
        
        for i in 0 ..< Int(FL) {
            
            // Here we won't go to eleven, three is the magic number.
            //floatData[i] = 0.3 * sinf(440.0*Float(i)*step)
            floatData[i] = 0.5 * sinf(freq * Float(i) * step)
            
            // This will just do a simple enevelope for the waveform,
            // so it'll not 'snap' at the beginning and the end of playing.
            //if i<4000 || i>40100 { floatData[i] *= 3.5*sinf(0.5*Float(i)*step) }
            //if i<4000 || i>40100 { floatData[i] *= 3.5*sinf(2 * Float.pi * freq * Float(i) * step) }
            
        }
        
        let playerNode = AVAudioPlayerNode()
        
        self.audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode,format: pcmBuffer.format)
        
        do {
            try audioEngine.start()
            
            // Starting to play sound would be faster with the call
            // to prepare, but we don't mind it here.
            //  playerNode.prepare(withFrameCount: 1)
        } catch let err as NSError {
            print("Oh, no!  \(err.code) \(err.domain)")
        }
        
        playerNode.play()
        playerNode.scheduleBuffer(pcmBuffer, at:nil, options: [.loops]) {
            // Code here is excuted, when sound is played,
            // but our sound never ends, as it is looping.
        }
        sleep(120)
        audioEngine.stop()
    }
}
