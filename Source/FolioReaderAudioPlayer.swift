//
//  FolioReaderAudioPlayer.swift
//  FolioReaderKit
//
//  Created by Kevin Jantzer on 1/4/16.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

//  TODO
//  - Import MediaPlayer and set "now playing" info for the lock screen
//  - Allow lock screen to control playing audio (I think that will have to be done in a view)
//

import UIKit
import AVFoundation


class FolioReaderAudioPlayer: NSObject, AVAudioPlayerDelegate {

    var playing = false
    var player: AVAudioPlayer!
    var currentHref: String!
    var currentFragment: String!
    var currentSmilFile: FRSmilFile!
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
        return playing
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
                player.rate = 1.5
                break
            case 3:
                player.rate = 2
                break
            default:
                break
            }
        }
    }

    func stop() {
        playing = false
        if( player != nil && player.playing ){
            player.stop()
            
            UIApplication.sharedApplication().idleTimerDisabled = false
        }
    }

    func pause() {
        playing = false
        if( player != nil && player.playing ){
            player.pause()
            
            UIApplication.sharedApplication().idleTimerDisabled = false
        }
    }

    func togglePlay() {
        isPlaying() ? pause() : playAudio()
    }

    func playAudio(){
        let currentPage = FolioReader.sharedInstance.readerCenter.currentPage
        currentPage.playAudio()
        
        UIApplication.sharedApplication().idleTimerDisabled = true
    }

    /**
     Play Audio (href/fragmentID)

     Begins to play audio for the given chapter (href) and text fragment.
     If this chapter does not have audio, it will delay for a second, then attempt to play the next chapter
    */
    func playAudio(href: String, fragmentID: String) {

        stop();

        let smilFile = book.smilFileForHref(href)

        // if no smil file for this href and the same href is being requested, we've hit the end. stop playing
        if smilFile == nil && currentHref != nil && href == currentHref {
            return
        }

        playing = true
        currentHref = href
        currentFragment = "#"+fragmentID
        currentSmilFile = smilFile

        // if no smil file, delay for a second, then move on to the next chapter
        if smilFile == nil {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "_autoPlayNextChapter", userInfo: nil, repeats: false)
            return
        }

        let fragment =  smilFile.parallelAudioForFragment(currentFragment)

        if( fragment != nil ){
            if _playFragment(fragment) {
                startPlayerTimer()
            }
        }
    }
    
    func _autoPlayNextChapter() {
        // if user has stopped playing, dont play the next chapter
        if isPlaying() == false { return }
        playNextChapter()
    }

    func playPrevChapter(){
        stopPlayerTimer()
        // Wait for "currentPage" to update, then request to play audio
        FolioReader.sharedInstance.readerCenter.changePageToPrevious() { () -> Void in
            if self.isPlaying() {
                self.playAudio()
            } else {
                self.pause()
            }
        }
    }
    
    func playNextChapter(){
        stopPlayerTimer()
        // Wait for "currentPage" to update, then request to play audio
        FolioReader.sharedInstance.readerCenter.changePageToNext { () -> Void in
            if self.isPlaying() {
                self.playAudio()
            }
        }
    }


    /**
     Play Fragment of audio

     Once an audio fragment begins playing, the audio clip will continue playing until the player timer detects
     the audio is out of the fragment timeframe.
    */
    private func _playFragment(smil: FRSmilElement!) -> Bool{

        if( smil == nil ){
            print("no more parallel audio to play")
            stop()
            return false
        }

        let textFragment = smil.textElement().attributes["src"]
        let audioFile = smil.audioElement().attributes["src"]

        currentBeginTime = smil.clipBegin()
        currentEndTime = smil.clipEnd()

        // new audio file to play, create the audio player
        if( player == nil || (audioFile != nil && audioFile != currentAudioFile) ){

            currentAudioFile = audioFile

            let fileURL = currentSmilFile.resource.basePath().stringByAppendingString("/"+audioFile!)
            let audioData = NSData(contentsOfFile: fileURL)
            if( audioData != nil ){
                player = try! AVAudioPlayer(data: audioData!)
                player.enableRate = true
                setRate(FolioReader.sharedInstance.currentAudioRate)
                player.prepareToPlay()
                player.delegate = self

            }else{
                print("could not read audio file:", audioFile)
                return false
            }
        }

        // if player is initialized properly, begin playing
        if( player != nil ){

            // the audio may be playing already, so only set the player time if it is NOT already within the fragment timeframe
            // this is done to mitigate milisecond skips in the audio when changing fragments
            if( player.currentTime < currentBeginTime || ( currentEndTime > 0 && player.currentTime > currentEndTime) ){
                player.currentTime = currentBeginTime;
            }

            player.play();

            // get the fragment ID so we can "mark" it in the webview
            let textParts = textFragment!.componentsSeparatedByString("#")
            let fragmentID = textParts[1];
            FolioReader.sharedInstance.readerCenter.audioMark(href: currentHref, fragmentID: fragmentID)
        }

        return true
    }

    /**
     Next Audio Fragment

     Gets the next audio fragment in the current smil file, or moves on to the next smil file
    */
    private func nextAudioFragment() -> FRSmilElement! {

        let smilFile = book.smilFileForHref(currentHref)

        if smilFile == nil { return nil }

        let smil = currentFragment == nil ? smilFile.parallelAudioForFragment(nil) : smilFile.nextParallelAudioForFragment(currentFragment)

        if( smil != nil ){
            currentFragment = smil.textElement().attributes["src"]
            return smil
        }

        currentHref = book.spine.nextChapter(currentHref)!.href
        currentFragment = nil
        currentSmilFile = smilFile

        if( currentHref == nil ){
            return nil
        }

        return nextAudioFragment()
    }

    // MARK: - audio timing events

    private func startPlayerTimer() {
        // we must add the timer in this mode in order for it to continue working even when the user is scrolling a webview
        playingTimer = NSTimer(timeInterval: 0.01, target: self, selector: "playerTimerObserver", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(playingTimer, forMode: NSRunLoopCommonModes)
    }

    private func stopPlayerTimer() {
        if( playingTimer != nil ){
            playingTimer.invalidate()
            playingTimer = nil
        }
    }

    func playerTimerObserver(){
        if( currentEndTime != nil && currentEndTime > 0 && player.currentTime > currentEndTime ){
            _playFragment(nextAudioFragment())
        }
    }

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        _playFragment(nextAudioFragment())
    }

}