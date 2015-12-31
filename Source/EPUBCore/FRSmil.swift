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


class FRSmilElement {
    var name: String // the name of the tag: <audio>
    var attributes: [String: String]

    init(name: String, attributes: [String:String]) {
        self.name = name
        self.attributes = attributes;
    }
};


class FRSmil: NSObject {
    var name: String // the name of the tag: <par>
    var id: String!
    var children: [FRSmilElement]

    init(name: String, id: String!) {
        self.name = name
        self.id = id
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
}
