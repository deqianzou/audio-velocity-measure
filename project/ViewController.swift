//
//  ViewController.swift
//  project
//
//  Created by JTDX on 2017/6/19.
//  Copyright © 2017年 texot. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var audioInput: TempiAudioInput!
    var spectralView: SpectralView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spectralView = SpectralView(frame: self.view.bounds)
        spectralView.backgroundColor = UIColor.white
        self.view.addSubview(spectralView)
        
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
        
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
        audioInput.startRecording()
        
        // audioPlay.playSound()
        let myThread = Thread(target:self,selector:#selector(ViewController.play),object:nil)
        myThread.start()
        
        
    }
    
    func play(){
        let Player = PlaySineWave()
        Player.play()
    }
    
    func gotSomeAudio(timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        let fft = FFT(withSize: numberOfFrames, sampleRate: 44100.0)
        
        fft.windowType = FFTWindowType.hanning
        fft.fftForward(samples)
        
        // Interpoloate the FFT data so there's one band per pixel.
        let screenWidth = UIScreen.main.bounds.size.width * UIScreen.main.scale
        fft.calculateLinearBands(minFrequency: 18000, maxFrequency: 20000, numberOfBands: Int(screenWidth))
        
        dispatch_main { () -> () in
            self.spectralView.fft = fft
            self.spectralView.setNeedsDisplay()
        }
    }
    
    override func didReceiveMemoryWarning() {
        NSLog("*** Memory!")
        super.didReceiveMemoryWarning()
    }
}

