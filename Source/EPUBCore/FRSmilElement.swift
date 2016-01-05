//
//  FRSmil.swift
//  Pods
//
//  Created by Kevin Jantzer on 12/30/15.
//
//

import UIKit

// Media Overlay Documentation
// http://www.idpf.org/accessibility/guidelines/content/overlays/overview.php#mo005-samp


class FRSmilElement: NSObject {
    var name: String // the name of the tag: <seq>, <par>, <text>, <audio>
    var attributes: [String: String]!
    var children: [FRSmilElement]

    init(name: String, attributes: [String:String]!) {
        self.name = name
        self.attributes = attributes
        self.children = [FRSmilElement]()
    }


    // if <par> tag, a <text> is required (http://www.idpf.org/epub/301/spec/epub-mediaoverlays.html#sec-smil-par-elem)
    func textElement() -> FRSmilElement! {
        return childWithName("text")
    }

    func audioElement() -> FRSmilElement! {
        return childWithName("audio")
    }

    func videoElement() -> FRSmilElement! {
        return childWithName("video")
    }

    func childWithName(name:String) -> FRSmilElement! {
        for el in children {
            if( el.name == name ){
                return el
            }
        }
        return nil;
    }

    // MARK: - Audio clip info

    func clipBegin() -> Double {
        return clockValueToSeconds(audioElement().attributes["clipBegin"])
    }

    func clipEnd() -> Double {
        return clockValueToSeconds(audioElement().attributes["clipEnd"])
    }

    // @TODO: need to test for what clock value is being used
    // http://www.idpf.org/epub/301/spec/epub-mediaoverlays.html#app-clock-examples
    func clockValueToSeconds(val: String!) -> Double {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let time = formatter.dateFromString(val!)

        if( time == nil ){
            return 0.0
        }

        formatter.dateFormat = "ss.SSS"
        let seconds = (formatter.stringFromDate(time!) as NSString).doubleValue

        formatter.dateFormat = "mm"
        let minutes = (formatter.stringFromDate(time!) as NSString).doubleValue

        formatter.dateFormat = "HH"
        let hours = (formatter.stringFromDate(time!) as NSString).doubleValue

        return seconds + (minutes*60) + (hours*60*60)
    }
}
