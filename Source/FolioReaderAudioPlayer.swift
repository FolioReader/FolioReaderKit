//
//  FolioReaderAudioPlayer.swift
//  Pods
//
//  Created by Kevin Jantzer on 1/4/16.
//
//  TODO
//  - Import MediaPlayer and set "now playing" info for the lock screen
//  - Allow lock screen to control playing audio (I think that will have to be done in a view)
//

import UIKit
import AVFoundation


class FolioReaderAudioPlayer: NSObject, AVAudioPlayerDelegate {

    var player: AVAudioPlayer!
    var currentHref: String!
    var currentFragment: String!
    var currentAudioFile: String!
    var currentBeginTime: Double!
    var currentEndTime: Double!
    var playingTimer: NSTimer!

    override init() {

        // this is needed to the audio can play even when the "silent/vibrate" toggle is on
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        try! session.setActive(true)
    }


    func isPlaying() -> Bool {
        return player != nil && player.playing
    }

    func setRate(rate: Int) {
        if( player != nil ){
            switch rate {
            case 0:
                player.rate = 0.5
                break
            case 1:
                player.rate = 1.0
                break
            case 2:
                player.rate = 1.25
                break
            case 3:
                player.rate = 1.5
                break
            default:
                break
            }
        }
    }

    func stop() {

        if( player != nil && player.playing ){
            player.stop()
        }
    }

    func pause() {
        if( player != nil && player.playing ){
            player.pause()
        }
    }

    func playAudio(){
        let currentPage = FolioReader.sharedInstance.readerCenter.currentPage
        currentPage.playAudio()
    }

    func playAudio(href: String, fragmentID: String) {

        stop();

        currentHref = href
        currentFragment = currentHref+"#"+fragmentID

        let smilFile = book.smilFileForHref(href)
        let smil =  smilFile.parallelAudioForFragment(currentFragment)

        if( smil != nil ){
            playFragment(smil)
            startPlayerTimer()
        }

    }

    func startPlayerTimer() {
        // we must add the timer in this mode in order for it to continue working even when the user is scrolling a webview
        playingTimer = NSTimer(timeInterval: 0.01, target: self, selector: "playerTimerObserver", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(playingTimer, forMode: NSRunLoopCommonModes)
    }

    func stopPlayerTimer() {
        if( playingTimer != nil ){
            playingTimer.invalidate()
            playingTimer = nil
        }
    }

    func playerTimerObserver(){
        if( currentEndTime != nil && currentEndTime > 0 && player.currentTime > currentEndTime ){
            playFragment(nextAudioFragment())
        }
    }

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playFragment(nextAudioFragment())
    }

    func playFragment(smil: FRSmilElement!){

        if( smil == nil ){
            print("no more parallel audio to play")
            stop()
            return
        }

        let textFragment = smil.textElement().attributes["src"]
        let audioFile = smil.audioElement().attributes["src"]

        currentBeginTime = smil.clipBegin()
        currentEndTime = smil.clipEnd()

//        print(currentBeginTime)
//        print(currentEndTime)

        // new audio file to play, create the audio player
        if( player == nil || (audioFile != nil && audioFile != currentAudioFile) ){

//            print("play file: "+audioFile!)
            currentAudioFile = audioFile

            let fileURL = book.smils.basePath.stringByAppendingString("/"+audioFile!)
            let audioData = NSData(contentsOfFile: fileURL)

            if( audioData != nil ){
                player = try! AVAudioPlayer(data: audioData!)
                player.enableRate = true
                setRate(FolioReader.sharedInstance.currentAudioRate)
                player.prepareToPlay()
                player.delegate = self

            }else{
                print("could not read audio file")
            }
        }

        if( player != nil ){

            if( player.currentTime < currentBeginTime || ( currentEndTime > 0 && player.currentTime > currentEndTime) ){
                player.currentTime = currentBeginTime;
            }

            player.play();

            //print("mark fragment: "+textFragment!)

            let textParts = textFragment!.componentsSeparatedByString("#")
            let fragmentID = textParts[1];

            FolioReader.sharedInstance.readerCenter.audioMark(href: currentHref, fragmentID: fragmentID)
        }

    }


    func nextAudioFragment() -> FRSmilElement! {

        let smilFile = book.smilFileForHref(currentHref)
        let smil = currentFragment == nil ? smilFile.parallelAudioForFragment(nil) : smilFile.nextParallelAudioForFragment(currentFragment)

        if( smil != nil ){
            currentFragment = smil.textElement().attributes["src"]
            return smil
        }

        currentHref = book.spine.nextChapter(currentHref)!.href
        currentFragment = nil

        if( currentHref == nil ){
            return nil
        }

        return nextAudioFragment()
    }


}