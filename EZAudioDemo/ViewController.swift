//
//  ViewController.swift
//  EZAudioDemo
//
//  Created by Cole Herrmann on 11/11/15.
//  Copyright © 2015 Tutor Clan. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation
import AVKit
import AudioKit
//import EZAudio

class ViewController: UIViewController
/*EZMicrophoneDelegate,
EZAudioFFTDelegate,
EZAudioPlayerDelegate,
EZAudioFileDelegate*/ {
    
//    let DSPLength: vDSP_Length = 4096
    
    @IBOutlet weak var songPathView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var songPathViewWidthConstant: NSLayoutConstraint!
    @IBOutlet weak var vocalIndicatorShellView: UIView!
    
//    var mic: EZMicrophone!
//    var fft: EZAudioFFTRolling!
//    var audioFile: EZAudioFile!
    var midiParser: MIDIParser!
    var vocalIndicatorView: UIView!
    var audioPlayer: AVAudioPlayer!
    
    let microphone = AKMicrophone()
    var analyzer: AKAudioAnalyzer!

    override func viewDidLoad() {
        super.viewDidLoad()

        AKSettings.shared().audioInputEnabled = true
        
        let path = NSBundle.mainBundle().pathForResource("01piano", ofType: "wav")
        let url = NSURL(fileURLWithPath: path!)
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
            try session.setActive(true)
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("error setting up audio session \(error)")
        }
        
//        mic = EZMicrophone(delegate: self)
//    
//        fft = EZAudioFFTRolling(windowSize: DSPLength,
//            sampleRate: Float(mic.audioStreamBasicDescription().mSampleRate),
//            delegate: self)

        openFileWithFileURLPath(url)
        
        analyzer = AKAudioAnalyzer(input: microphone.output)
        
        AKOrchestra.addInstrument(microphone)
        AKOrchestra.addInstrument(analyzer)
        
        midiParser = MIDIParser(midiPath: NSBundle.mainBundle().URLForResource("01midi", withExtension: "mid")!)
        drawMIDILineToView()

    }
    
    func drawMIDILineToView() {
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        songPathView.setNeedsLayout()
        songPathView.layoutIfNeeded()
        
        let path = midiParser.createPathFromMIDI(forView: songPathView)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = UIColor.whiteColor().CGColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        
        songPathView.layer.addSublayer(shapeLayer)
        
        let newConstant = path.bounds.width - view.frame.size.width
        songPathViewWidthConstant.constant = newConstant
        view.layoutIfNeeded()
        
        vocalIndicatorView = UIView(frame: CGRectMake(30, 0, 30, 30))//createIndicatorView()
        vocalIndicatorView.layer.cornerRadius = 15
        vocalIndicatorView.backgroundColor = .whiteColor()
        
        vocalIndicatorShellView.addSubview(vocalIndicatorView)
    }
    
    func createIndicatorView() -> UIView {
        let views = NSBundle.mainBundle().loadNibNamed("VocalIndicatorView", owner: self, options: nil)
        let indicator = views.first as! UIView
        indicator.frame = CGRectMake(30, 0, 30, 30)
        return indicator
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        mic.startFetchingAudio()
        
        animateSong()
        
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
        analyzer.start()
        microphone.start()
        
        print(songPathView.frame)
        
        NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("updateUI"), userInfo: nil, repeats: true)

        
    }
    
    func animateSong() {
    let duration = Double(midiParser.durationForChords())
        
       UIView.animateWithDuration(duration/2.0, delay: 0.0, options: .CurveLinear, animations: { () -> Void in
            self.scrollView.contentOffset.x = self.songPathView.frame.size.width
        }) { completed in
            self.animateSong()
        }
    }
    
    func openFileWithFileURLPath(filePath: NSURL) {
        
        print(filePath)
//        audioFile = EZAudioFile(URL: filePath)
//        audioFile.delegate = self
        
    }
    
    func updateUI() {
        if analyzer.trackedAmplitude.value > 0.01 {
//            frequencyLabel.text = String(format: "%0.1f", analyzer.trackedFrequency.value)
            
            let frequency = analyzer.trackedFrequency.value
            print(frequency)
            dispatch_async(dispatch_get_main_queue(), {
                UIView.animateWithDuration(0.1, animations: { () -> Void in

                    self.vocalIndicatorView.frame = CGRectMake(self.vocalIndicatorView.frame.origin.x,
                        self.songPathView.frame.size.height - (CGFloat(frequency) * yMultiplier),
                        30,
                        30)
                })
            })

//            while (frequency > Float(noteFrequencies[noteFrequencies.count-1])) {
//                frequency = frequency / 2.0
//            }
//            while (frequency < Float(noteFrequencies[0])) {
//                frequency = frequency * 2.0
//            }
//            
//            normalizedFrequency.value = frequency
//            normalizedFrequencyPlot.updateWithValue(frequency)
            
//            var minDistance: Float = 10000.0
//            var index = 0
//            
//            for (var i = 0; i < noteFrequencies.count; i++){
//                
//                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
//                if (distance < minDistance){
//                    index = i
//                    minDistance = distance
//                }
//            }
//            
//            let octave = Int(log2f(analyzer.trackedFrequency.value / frequency))
//            let noteName = String(format: "%@%d", noteNamesWithSharps[index], octave, noteNamesWithFlats[index], octave)
//            noteNameLabel.text = noteName
        }
//        amplitudeLabel.text = String(format: "%0.2f", analyzer.trackedAmplitude.value)
    }
//
    

//    func microphone(microphone: EZMicrophone!,
//        hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>,
//        withBufferSize bufferSize: UInt32,
//        withNumberOfChannels numberOfChannels: UInt32) {
//            
//            print(numberOfChannels)
//                        
//            let firstArray: UnsafeMutablePointer<Float> = buffer[0]
//            let float = firstArray[0]
//            print("the float: \(float)")
//            
//            fft.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
//    }
//    
//    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
//        
//        let maxFrequency = fft.maxFrequency
//
////        print("max mag \(fft.maxFrequencyMagnitude)")
////        print("magnitude \(fft.maxFrequencyMagnitude)")
//        
//        dispatch_async(dispatch_get_main_queue(), {
//            UIView.animateWithDuration(0.1, animations: { () -> Void in
//                
//                self.vocalIndicatorView.frame = CGRectMake(self.vocalIndicatorView.frame.origin.x,
//                    self.songPathView.frame.size.height - (CGFloat(maxFrequency) * 0.4),
//                    30,
//                    30)
//                
////                print(CGFloat(maxFrequency) * 0.4)
////                print("max mag \(fft.maxFrequency)")
//
//            })
//        })
//        
//    }

}

