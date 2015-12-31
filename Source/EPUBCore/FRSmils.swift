//
//  FRSmils.swift
//  Pods
//
//  Created by Kevin Jantzer on 12/30/15.
//
//


import UIKit

struct FRSmilFile {
    var resource: FRResource
    var data = [FRSmil]()

    init(resource: FRResource){
        self.resource = resource;
    }

    // MARK: - shortcuts

    func ID() -> String {
        return self.resource.id;
    }

    func href() -> String {
        return self.resource.href;
    }

    // MARK: - data methods

    /**
    Returns an <audio> tag which contains info about parallel audio to be played
    */
    func parallelAudioForFragment(fragment: String) -> FRSmilElement! {
        for smil in data {

            // if its a <par> (parallel) element and has a <text> node with the matching fragment
            if( smil.name == "par" && smil.textElement().name == href()+"#"+fragment ){
                return smil.audioElement()
            }
        }
        return nil;
    }

    /**
     Returns text fragment for the current audio time given
    */
    func parallelFragmentForAudio(currentTime: String) -> String! {
        for smil in data {

            // if its a <par> (parallel) element
            if( smil.name == "par" && smil.audioElement() != nil ){

                let audioEl = smil.audioElement()

            }
        }
        return nil;
    }
}


class FRSmils: NSObject {
    var smils = [String: FRSmilFile]()

    /**
     Adds a smil to the smils.
     */
    func add(smil: FRSmilFile) {
        self.smils[smil.resource.href] = smil
    }

    /**
     Gets the resource with the given href.
     */
    func getByHref(href: String) -> FRSmilFile? {
        for smil in smils.values {
            if smil.resource.href == href {
                return smil
            }
        }
        return nil
    }

    /**
     Gets the resource with the given id.
     */
    func getById(ID: String) -> FRSmilFile? {
        for smil in smils.values {
            if smil.resource.id == ID {
                return smil
            }
        }
        return nil
    }
}