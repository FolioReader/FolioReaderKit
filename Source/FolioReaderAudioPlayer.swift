//
//  FolioReaderAudioPlayer.swift
//  FolioReaderKit
//
//  Created by Kevin Jantzer on 1/4/16.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

open class FolioReaderAudioPlayer: NSObject {
    var isTextToSpeech = false
    var synthesizer: AVSpeechSynthesizer!
    var playing = false
    var player: AVAudioPlayer?
    var currentHref: String!
    var currentFragment: String!
    var currentSmilFile: FRSmilFile!
    var currentAudioFile: String!
    var currentBeginTime: Double!
    var currentEndTime: Double!
    var playingTimer: Timer!
    var registeredCommands = false
    var completionHandler: () -> Void = {}
    var utteranceRate: Float = 0
    
    // MARK: Init
    
    override init() {
        super.init()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        // this is needed to the audio can play even when the "silent/vibrate" toggle is on
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        try! session.setActive(true)
        
        updateNowPlayingInfo()
    }
    
    deinit {
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    // MARK: Reading speed

    func setRate(_ rate: Int) {
        if let player = player {
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
            
            updateNowPlayingInfo()
        }
        if synthesizer != nil {
            // Need to change between version IOS
            // http://stackoverflow.com/questions/32761786/ios9-avspeechutterance-rate-for-avspeechsynthesizer-issue
            if #available(iOS 9, *) {
                switch rate {
                case 0:
                    utteranceRate = 0.42
                    break
                case 1:
                    utteranceRate = 0.5
                    break
                case 2:
                    utteranceRate = 0.53
                    break
                case 3:
                    utteranceRate = 0.56
                    break
                default:
                    break
                }
            } else {
                switch rate {
                case 0:
                    utteranceRate = 0
                    break
                case 1:
                    utteranceRate = 0.06
                    break
                case 2:
                    utteranceRate = 0.15
                    break
                case 3:
                    utteranceRate = 0.23
                    break
                default:
                    break
                }
            }
            
            updateNowPlayingInfo()
        }
    }
    
    // MARK: Play, Pause, Stop controls

    func stop(immediate: Bool = false) {
        playing = false
		if !isTextToSpeech {
            if let player = player , player.isPlaying {
				player.stop()
			}
		} else {
            stopSynthesizer(immediate: immediate, completion: nil)
		}
        
//        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    func stopSynthesizer(immediate: Bool = false, completion: (() -> Void)? = nil) {
        synthesizer.stopSpeaking(at: immediate ? .immediate : .word)
        completion?()
    }

    func pause() {
        playing = false
        
        if !isTextToSpeech {
            if let player = player , player.isPlaying {
                player.pause()
            }
        } else {
			if synthesizer.isSpeaking {
				synthesizer.pauseSpeaking(at: .word)
			}
        }
        
//        UIApplication.sharedApplication().idleTimerDisabled = false
    }

    func togglePlay() {
        isPlaying() ? pause() : play()
    }

    func play() {
        if book.hasAudio() {
            guard let currentPage = FolioReader.shared.readerCenter?.currentPage else { return }
            currentPage.webView.js("playAudio()")
        } else {
            readCurrentSentence()
        }
        
//        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    func isPlaying() -> Bool {
        return playing
    }

    /**
     Play Audio (href/fragmentID)

     Begins to play audio for the given chapter (href) and text fragment.
     If this chapter does not have audio, it will delay for a second, then attempt to play the next chapter
    */
    func playAudio(_ href: String, fragmentID: String) {
        isTextToSpeech = false
        
        stop()

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
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(_autoPlayNextChapter), userInfo: nil, repeats: false)
            return
        }

        let fragment = smilFile?.parallelAudioForFragment(currentFragment)

        if fragment != nil {
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

    func playPrevChapter() {
        stopPlayerTimer()
        // Wait for "currentPage" to update, then request to play audio
        FolioReader.shared.readerCenter?.changePageToPrevious {
            if self.isPlaying() {
                self.play()
            } else {
                self.pause()
            }
        }
    }

    func playNextChapter() {
        stopPlayerTimer()
        // Wait for "currentPage" to update, then request to play audio
        FolioReader.shared.readerCenter?.changePageToNext {
            if self.isPlaying() {
                self.play()
            }
        }
    }


    /**
     Play Fragment of audio

     Once an audio fragment begins playing, the audio clip will continue playing until the player timer detects
     the audio is out of the fragment timeframe.
    */
    @discardableResult fileprivate func _playFragment(_ smil: FRSmilElement!) -> Bool {

        if smil == nil {
            print("no more parallel audio to play")
            stop()
            return false
        }

        let textFragment = smil.textElement().attributes["src"]
        let audioFile = smil.audioElement().attributes["src"]

        currentBeginTime = smil.clipBegin()
        currentEndTime = smil.clipEnd()

        // new audio file to play, create the audio player
        if player == nil || (audioFile != nil && audioFile != currentAudioFile) {

            currentAudioFile = audioFile

            let fileURL = currentSmilFile.resource.basePath() + ("/"+audioFile!)
            let audioData = try? Data(contentsOf: URL(fileURLWithPath: fileURL))
            
            do {
            
                player = try AVAudioPlayer(data: audioData!)
                
                guard let player = player else { return false }
                
                setRate(FolioReader.currentAudioRate)
                player.enableRate = true
                player.prepareToPlay()
                player.delegate = self
                
                updateNowPlayingInfo()
            } catch {
                print("could not read audio file:", audioFile ?? "nil")
                return false
            }
        }

        // if player is initialized properly, begin playing
        guard let player = player else { return false }

        // the audio may be playing already, so only set the player time if it is NOT already within the fragment timeframe
        // this is done to mitigate milisecond skips in the audio when changing fragments
        if player.currentTime < currentBeginTime || ( currentEndTime > 0 && player.currentTime > currentEndTime) {
            player.currentTime = currentBeginTime;
            updateNowPlayingInfo()
        }

        player.play()

        // get the fragment ID so we can "mark" it in the webview
        let textParts = textFragment!.components(separatedBy: "#")
        let fragmentID = textParts[1];
        FolioReader.shared.readerCenter?.audioMark(href: currentHref, fragmentID: fragmentID)

        return true
    }

    /**
     Next Audio Fragment

     Gets the next audio fragment in the current smil file, or moves on to the next smil file
    */
    fileprivate func nextAudioFragment() -> FRSmilElement! {

        let smilFile = book.smilFileForHref(currentHref)

        if smilFile == nil { return nil }

        let smil = currentFragment == nil ? smilFile?.parallelAudioForFragment(nil) : smilFile?.nextParallelAudioForFragment(currentFragment)

        if smil != nil {
            currentFragment = smil?.textElement().attributes["src"]
            return smil
        }

        currentHref = book.spine.nextChapter(currentHref)!.href
        currentFragment = nil
        currentSmilFile = smilFile

        if currentHref == nil {
            return nil
        }

        return nextAudioFragment()
    }
    
    func playText(_ href: String, text: String) {
        isTextToSpeech = true
        playing = true
        currentHref = href
        
        if synthesizer == nil {
            synthesizer = AVSpeechSynthesizer()
            synthesizer.delegate = self
            setRate(FolioReader.currentAudioRate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = utteranceRate
        utterance.voice = AVSpeechSynthesisVoice(language: book.metadata.language)
        
        if synthesizer.isSpeaking {
            stopSynthesizer()
        }
        synthesizer.speak(utterance)
        
        updateNowPlayingInfo()
    }
    
    // MARK: TTS Sentence
    
    func speakSentence() {
		guard let
			readerCenter = FolioReader.shared.readerCenter,
			let currentPage = readerCenter.currentPage else {
				return
		}

        let sentence = currentPage.webView.js("getSentenceWithIndex('\(book.playbackActiveClass())')")
        
        if sentence != nil {
            let chapter = readerCenter.getCurrentChapter()
            let href = chapter != nil ? chapter!.href : "";
            playText(href!, text: sentence!)
        } else {
            if readerCenter.isLastPage() {
                stop()
            } else {
                readerCenter.changePageToNext()
            }
        }
    }
    
    func readCurrentSentence() {
        guard synthesizer != nil else { return speakSentence() }
        
        if synthesizer.isPaused {
            playing = true
            synthesizer.continueSpeaking()
        } else {
            if synthesizer.isSpeaking {
                stopSynthesizer(immediate: false, completion: {
                    if let currentPage = FolioReader.shared.readerCenter?.currentPage {
                        currentPage.webView.js("resetCurrentSentenceIndex()")
                    }
                    self.speakSentence()
                })
            } else {
                speakSentence()
            }
        }
    }
    
    // MARK: - Audio timing events

    fileprivate func startPlayerTimer() {
        // we must add the timer in this mode in order for it to continue working even when the user is scrolling a webview
        playingTimer = Timer(timeInterval: 0.01, target: self, selector: #selector(playerTimerObserver), userInfo: nil, repeats: true)
        RunLoop.current.add(playingTimer, forMode: RunLoopMode.commonModes)
    }

    fileprivate func stopPlayerTimer() {
        if playingTimer != nil {
            playingTimer.invalidate()
            playingTimer = nil
        }
    }

    func playerTimerObserver() {
        guard let player = player else { return }
        
        if currentEndTime != nil && currentEndTime > 0 && player.currentTime > currentEndTime {
            _playFragment(nextAudioFragment())
        }
    }
    
    // MARK: - Now Playing Info and Controls
    
    /**
     Update Now Playing info
     
     Gets the book and audio information and updates on Now Playing Center
     */
    func updateNowPlayingInfo() {
        var songInfo = [String: AnyObject]()
        
        // Get book Artwork
        if let coverImage = book.coverImage, let artwork = UIImage(contentsOfFile: coverImage.fullHref) {
            let albumArt = MPMediaItemArtwork(image: artwork)
            songInfo[MPMediaItemPropertyArtwork] = albumArt
        }
        
        // Get book title
        if let title = book.title() {
            songInfo[MPMediaItemPropertyAlbumTitle] = title as AnyObject?
        }
        
        // Get chapter name
        if let chapter = getCurrentChapterName() {
            songInfo[MPMediaItemPropertyTitle] = chapter as AnyObject?
        }
        
        // Get author name
        if let author = book.metadata.creators.first {
            songInfo[MPMediaItemPropertyArtist] = author.name as AnyObject?
        }
        
        // Set player times
        if let player = player , !isTextToSpeech {
            songInfo[MPMediaItemPropertyPlaybackDuration] = player.duration as AnyObject?
            songInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate as AnyObject?
            songInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime ] = player.currentTime as AnyObject?
        }
        
        // Set Audio Player info
        MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
        
        registerCommandsIfNeeded()
    }
    
    /**
     Get Current Chapter Name
     
     This is done here and not in ReaderCenter because even though `currentHref` is accurate,
     the `currentPage` in ReaderCenter may not have updated just yet
     */
    func getCurrentChapterName() -> String? {
        guard let chapter = FolioReader.shared.readerCenter?.getCurrentChapter() else {
            return nil
        }
        
        currentHref = chapter.href
        
        for item in book.flatTableOfContents {
            if let resource = item.resource , resource.href == currentHref {
                return item.title
            }
        }
        return nil
    }
    
    /**
     Register commands if needed, check if it's registered to avoid register twice.
     */
    func registerCommandsIfNeeded() {
        
        guard !registeredCommands else { return }
        
        let command = MPRemoteCommandCenter.shared()
        command.previousTrackCommand.isEnabled = true
        command.previousTrackCommand.addTarget(self, action: #selector(playPrevChapter))
        command.nextTrackCommand.isEnabled = true
        command.nextTrackCommand.addTarget(self, action: #selector(playNextChapter))
        command.pauseCommand.isEnabled = true
        command.pauseCommand.addTarget(self, action: #selector(pause))
        command.playCommand.isEnabled = true
        command.playCommand.addTarget(self, action: #selector(play))
        command.togglePlayPauseCommand.isEnabled = true
        command.togglePlayPauseCommand.addTarget(self, action: #selector(togglePlay))
        
        registeredCommands = true
    }
}

// MARK: AVSpeechSynthesizerDelegate

extension FolioReaderAudioPlayer: AVSpeechSynthesizerDelegate {
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        completionHandler()
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if isPlaying() {
            readCurrentSentence()
        }
    }
}

// MARK: AVAudioPlayerDelegate

extension FolioReaderAudioPlayer: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        _playFragment(nextAudioFragment())
    }
}
