//
//  SpectralView.swift
//  project
//
//  Created by JTDX on 2017/6/19.
//  Copyright © 2017年 texot. All rights reserved.
//

import UIKit

class SpectralView: UIView {
    
    var fft: FFT!
    var minHz = 18600
    var maxHz = 19400
    var lll : Int = 1
    var baseMag = [Float](repeating: 0.0, count: 801)
    var nowMag = [Float](repeating: 0.0, count: 801)
    
    override func draw(_ rect: CGRect) {
        
        if fft == nil {
            return
        }
        
        let context = UIGraphicsGetCurrentContext()
        
        self.drawSpectrum(context: context!)
        
        // We're drawing static labels every time through our drawRect() which is a waste.
        // If this were more than a demo we'd take care to only draw them once.
        self.drawLabels(context: context!)
        
        self.drawVelocity(context: context!)
    }
    
    private func drawSpectrum(context: CGContext) {
        let viewWidth = self.bounds.size.width
        let viewHeight = self.bounds.size.height
        let plotYStart: CGFloat = 48.0
        
        context.saveGState()
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -viewHeight / 3 * 2)
        
        let colors = [UIColor.green.cgColor, UIColor.yellow.cgColor, UIColor.red.cgColor]
        let gradient = CGGradient(
            colorsSpace: nil, // generic color space
            colors: colors as CFArray,
            locations: [0.0, 0.3, 0.6])
        
        var x: CGFloat = 0.0
        
        let count = fft.numberOfBands
        
        // Draw the spectrum.
        let maxDB: Float = 64.0
        let minDB: Float = -32.0
        let headroom = maxDB - minDB
        let colWidth = round_device_scale(d: viewWidth / CGFloat(count))
        
        for i in 0..<count {
            let magnitude = fft.magnitudeAtBand(i)
            
            // Incoming magnitudes are linear, making it impossible to see very low or very high values. Decibels to the rescue!
            var magnitudeDB = FFT.toDB(magnitude)
            
            // Normalize the incoming magnitude so that -Inf = 0
            magnitudeDB = max(0, magnitudeDB + abs(minDB))
            
            let dbRatio = min(1.0, magnitudeDB / headroom)
            //let magnitudeNorm = CGFloat(dbRatio) * viewHeight
            let magnitudeNorm = CGFloat(dbRatio) * viewWidth * 1.5
            
            let colRect: CGRect = CGRect(x: x, y: plotYStart, width: colWidth, height: magnitudeNorm)
            //let colRect: CGRect = CGRect(x: plotYStart, y: x, width: colWidth, height: magnitudeNorm)
            
            let startPoint = CGPoint(x: viewWidth / 2, y: 0)
            let endPoint = CGPoint(x: viewWidth / 2, y: viewHeight)
            
            context.saveGState()
            context.clip(to: colRect)
            context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
            context.restoreGState()
            
            x += colWidth
        }

        
        context.restoreGState()
    }
    
    private func drawLabels(context: CGContext) {
        let viewWidth = self.bounds.size.width
        let viewHeight = self.bounds.size.height
        
        context.saveGState()
        context.translateBy(x: 0, y: viewHeight)
        
        
        let pointSize: CGFloat = 15.0
        let font = UIFont.systemFont(ofSize: pointSize, weight: UIFontWeightRegular)
        
        let freqLabelStr = "Frequency (kHz)"
        var attrStr = NSMutableAttributedString(string: freqLabelStr)
        attrStr.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, freqLabelStr.characters.count))
        attrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSMakeRange(0, freqLabelStr.characters.count))
        
        var x: CGFloat = viewWidth / 2.0 - attrStr.size().width / 2.0
        
        attrStr.draw(at: CGPoint(x: x, y: -22 - viewHeight / 3))
        
        let labelStrings: [String] = ["18", "18.5", "19", "19.5", "20"]
        
        for i in 0..<labelStrings.count {
            let str = labelStrings[i]
            //let freq = labelValues[i]
            
            attrStr = NSMutableAttributedString(string: str)
            attrStr.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, str.characters.count))
            attrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0, str.characters.count))
            
            //x = freq / samplesPerPixel - pointSize / 2.0
            x = CGFloat(i) * (viewWidth  - pointSize - 2.0) / 4
            attrStr.draw(at: CGPoint(x: x, y: -40 - viewHeight / 3))
            //attrStr.draw(at: CGPoint(x: x, y: 0))
        }
        
        context.restoreGState()
    }
    
    private func drawVelocity(context: CGContext){
    	// To calculate the velocity, we use Doppler effect as
    	// v = Fs / F * C
    	// where Fs is the frequency shift of the received soundwave,
    	//       F is the initial frequency or the one of transmitted wave
    	//       C is the velocity of sound, usually thought as 340 m/s
        let viewWidth = self.bounds.size.width
        let viewHeight = self.bounds.size.height
        var centerFreq = 19036 + 42
        var left : Int = minHz
        var right : Int = minHz
        //var s : Float = 0.0

        if(lll < 200){
            lll += 1
            //print(lll)
        }
        if(lll == 200 && baseMag[400] == 0.0){
            
        	for i in minHz..<maxHz{
        		self.baseMag[i-self.minHz] = fft.magnitudeAtFrequency(Float(i))
                //print("base[\(i-minHz)] = \(baseMag[i - minHz]), freq(\(i))=\(fft.magnitudeAtFrequency(Float(i)))")
                if fft.magnitudeAtFrequency(Float(i)) > fft.magnitudeAtFrequency(Float(left)){
                    left = i
                }
                if fft.magnitudeAtFrequency(Float(i)) >= fft.magnitudeAtFrequency(Float(right)){
                    right = i
                }
        	}
            centerFreq = (left + right) / 2
            for j in minHz..<maxHz{
                baseMag[j - minHz] /= fft.magnitudeAtFrequency(Float(centerFreq))
            }
            print("centerFreq = \(centerFreq)")
            print("base[400] = \(baseMag[400]), Frq(19000) = \(fft.magnitudeAtFrequency(19000.0))")
            print("left = \(left), right = \(right)")
        }
        //print(lll)
        

        context.saveGState()
        context.translateBy(x: 0, y: viewHeight)
        
        if lll == 200{
        let flagArray = [Float](repeating: 0.0, count: 801)

        //let time_interval:Float = 1024 / 44100
        if nowMag != flagArray{

            let freqPeak = fft.magnitudeAtFrequency(Float(centerFreq))
            var deltaMag : Float = 0.0
            var maxDelta : Float = 0.0
            var Fs : Float = 18000.0
            //print("hi")// cannot getin here
            for i in minHz..<maxHz{
                nowMag[i - minHz] = fft.magnitudeAtFrequency(Float(i)) / freqPeak

                deltaMag = nowMag[i - minHz] - baseMag[i - minHz]
                //print("deltaMag = \(deltaMag)")
                if (deltaMag > maxDelta && i < left) || (deltaMag > maxDelta && i > right){
                    //print("nowMag[]\(i) = \(nowMag[i-minHz]), base[]\(i) = \(baseMag[i-minHz])")
                    maxDelta = deltaMag
                    Fs = Float(i)
                }
            }
            
            if maxDelta >= 0.02 {
            	//let Fs : Float = Float(index) * 2000.0 / Float(count) + 18000// the frequency represented by index
                //print(index)
                fft.velocity = (Fs - 19000) / 19000 * 340
                //print("v1 = \(fft.velocity), Fs = \(Fs)")
                //s = fft.calculateDistanceShift(time_interval: time_interval)
            }else{
            	//fft.distanceShift = fft.distanceShift + fft.velocity * time_interval
                //s = fft.calculateDistanceShift(time_interval: time_interval)
                fft.velocity = 0.0
            }

        }else{
            print("2")
            for i in minHz..<maxHz{
                let freqPeak = fft.magnitudeAtFrequency(Float(centerFreq))
                nowMag[i - minHz] = fft.magnitudeAtFrequency(Float(i)) / freqPeak
                //fft.distanceShift = fft.distanceShift + fft.velocity * time_interval
                fft.velocity = 0.0
            }
            }}
        
        let pointSize: CGFloat = 15.0
        let font = UIFont.systemFont(ofSize: pointSize, weight: UIFontWeightRegular)
        
        let v : String = "v = \(fft.velocity) m/s"
        //let sStr : String = "s = \(s) cm"
        let velocityStr = NSMutableAttributedString(string: v)
        velocityStr.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, v.characters.count))
        velocityStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSMakeRange(0, v.characters.count))

        /*let shiftStr = NSMutableAttributedString(string: sStr)
        shiftStr.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, sStr.characters.count))
        shiftStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSMakeRange(0, sStr.characters.count))*/
        
        let x: CGFloat = viewWidth / 2.0 - velocityStr.size().width / 2.0
        
        velocityStr.draw(at: CGPoint(x: x, y: 50 - viewHeight / 3 ))
        //shiftStr.draw(at: CGPoint(x: x, y: 20 - viewHeight / 3 ))
        context.restoreGState()
    }
    
}

