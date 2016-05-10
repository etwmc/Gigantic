//
//  ExchangeEngine.swift
//  Gigantic-Swift
//
//  Created by Wai Man Chan on 7/6/15.
//
//

import Foundation
import AVFoundation

struct Exchange {
    let message: String
    let requireExchange: Bool
}

protocol PlayerSource {
    func seekNextTrack()->NSURL?
    func pushNextTrack()->NSURL
}
class Player {
    let playerQueue = dispatch_queue_create("Player Queue", DISPATCH_QUEUE_CONCURRENT)
    var source: PlayerSource?
    var currnetPlayer: AVAudioPlayer?
    func setSource(source: PlayerSource) {
        self.source = source
        dispatch_async(playerQueue, { () -> Void in
            while(true) {
                
                //Play a track
                let nextTrackURL = source.pushNextTrack()
                do {
                    self.currnetPlayer = nil
                    self.currnetPlayer = try AVAudioPlayer(contentsOfURL: nextTrackURL)
                    self.currnetPlayer?.play()
                } catch {
                    assert(false, "Failed to play: "+nextTrackURL.absoluteString)
                }
            }
        })
    }
}

private class _ExchangeEngine: PlayerSource {
    
    //Main Output
    var outputCounter = dispatch_semaphore_create(0)
    private func incrementCounter() {
        dispatch_semaphore_signal(outputCounter)
    }
    
    //Music Player Part
    var tracks = [NSURL]()
    var numberOfTrack = dispatch_semaphore_create(0)
    private func pushNowPlaying(newTrack: NSURL) {
        tracks.append(newTrack)
        dispatch_semaphore_signal(numberOfTrack)
    }
    private func seekNextTrack()->NSURL? {
        return tracks.last
    }
    private func pushNextTrack()->NSURL {
        dispatch_semaphore_wait(numberOfTrack, DISPATCH_TIME_FOREVER)
        let track = tracks.removeLast()
        return track
    }
    let audioPlayer = Player()
    
    //Dialog Output Part
    
    var bufferModSemaphore = dispatch_semaphore_create(1)
    
    var priorityList = [String]()
    var buffer = [Array<Exchange>]()
    
    private func beginModBuffer() { dispatch_semaphore_wait(bufferModSemaphore, DISPATCH_TIME_FOREVER) }
    private func endModBuffer() { dispatch_semaphore_signal(bufferModSemaphore) }
    
    func addMessage(priority: Int, message: Exchange) {
        beginModBuffer()
        buffer[priority].append(message)
        incrementCounter()
        endModBuffer()
    }
    
    static let engine = _ExchangeEngine()
    class func sharedOutputEngine()->_ExchangeEngine {
        return engine
    }
}

class ExchangeEngine {
    private let engine = _ExchangeEngine.sharedOutputEngine()
    internal let priority: Int
    
    init() {
        priority = 0
    }
    
    func pushDialog(dialog: String, dialogExchange: Bool) {
        let dialogExchange = Exchange(message: dialog, requireExchange: dialogExchange)
        engine.addMessage(priority, message: dialogExchange)
    }
    
    func pushNotification(notification: String) {
        let exchange = Exchange(message: notification, requireExchange: false)
        engine.addMessage(priority, message: exchange)
    }
    
    func pushNowPlaying(nextTrack: NSURL) {
        
    }
}