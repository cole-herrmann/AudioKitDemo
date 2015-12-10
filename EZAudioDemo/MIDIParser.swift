//
//  MIDIParser.swift
//  EZAudioDemo
//
//  Created by Cole Herrmann on 11/23/15.
//  Copyright © 2015 Tutor Clan. All rights reserved.
//

import Foundation
import UIKit
import CoreMIDI
import CoreAudio
import AudioToolbox
import MIKMIDI

let yMultiplier: CGFloat = 0.3

struct MIDIChord {
    var MIDINoteArray: [MIKMIDINoteEvent]
    
    init(MIDINoteArray: [MIKMIDINoteEvent]) {
        self.MIDINoteArray = MIDINoteArray
    }
    
    mutating func addNote(note: MIKMIDINoteEvent) {
        MIDINoteArray.append(note)
    }
    
    func isChord() -> Bool {
        return MIDINoteArray.count > 0
    }
}

class MIDIParser {
    
    enum MIDIParsingError: ErrorType {
        case ErrorCreatingSequence(url: NSURL)
    }
    
    let midiPath: NSURL
    var chords: [MIDIChord] = [MIDIChord]()
    
    required init(midiPath: NSURL) {
        self.midiPath = midiPath
        do {
            self.chords = try parseMIDI()
        } catch {
            print("error instantiating midi chords")
        }
    }
    
    private func parseMIDI() throws -> [MIDIChord] {
        do {
            let sequence = try MIKMIDISequence(fileAtURL: midiPath)
            let track = sequence.tracks.first!

            print("Track name: \(track.trackNumber)")
            print("Track length: \(track.length)")
                        
            let eventsFiltered = track.events.filter() {
                guard let _ = $0 as? MIKMIDINoteEvent else {
                    return false
                }
                
                return true
            } as! [MIKMIDINoteEvent]
            
            var chord = MIDIChord(MIDINoteArray: [MIKMIDINoteEvent]())
            var chords = [MIDIChord]()
            
            for (i, event) in eventsFiltered.enumerate() {
                if i > 0 {
                    if event.duration == eventsFiltered[i - 1].duration &&
                    event.endTimeStamp == eventsFiltered[i - 1].endTimeStamp {
                        chord.addNote(event)
                    } else {
                        chords.append(chord)
                        chord = MIDIChord(MIDINoteArray: [MIKMIDINoteEvent]())
                        chord.addNote(event)
                    }
                } else {
                    chord.addNote(event)
                }
                
                print("Note : \(event.noteLetterAndOctave) and duration: \(event.duration) and end time stamp: \(event.endTimeStamp) and frequency: \(event.frequency)")
            }
            
//            print("CHORDS COUNT: \(chords.count)")
//            print("EVENTS COUNT: \(eventsFiltered.count)")
//            print("TOTAL CHORDS DURATION: \(durationForChords())")
            
            return chords

        } catch {
            print("error instantiating midi sequence")
            throw MIDIParsingError.ErrorCreatingSequence(url: midiPath)
        }
        
    }
    
    func createPointsFromChords(forView view: UIView) -> [CGPoint] {
        var points: [CGPoint] = [CGPoint]()
        let xMultiplier: CGFloat = 60
        for (i, chord) in chords.enumerate() {
            var x1: CGFloat
            let y1 = CGFloat(chord.MIDINoteArray.first!.frequency) * yMultiplier
            if i == 0 {
                x1 = 0
            } else {
                x1 = CGFloat(chords[i-1].MIDINoteArray.first!.endTimeStamp)
            }
            points.append(CGPoint(x: x1 * xMultiplier, y: view.frame.size.height - y1))
            print(points.last!)
            let y2 = CGFloat(chord.MIDINoteArray.first!.frequency) * yMultiplier
            points.append(CGPoint(x: CGFloat(chord.MIDINoteArray.first!.endTimeStamp) * xMultiplier, y: view.frame.size.height - y2))
            print(points.last!)

        }
        
        return points

    }
    
    func createPathFromMIDI(forView view: UIView) -> UIBezierPath {
        let points = createPointsFromChords(forView: view)
        
        let path = UIBezierPath()
        path.moveToPoint(points.first!)
        
        for var i = 1; i < points.count; i++ {
            path.addLineToPoint(points[i])
        }

        return path
    }
    
    func durationForChords() -> Float {
        return chords.reduce(0, combine: { accum, chord in chord.MIDINoteArray.first!.duration + accum })
    }
    
}
