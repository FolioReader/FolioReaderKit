//
//  AppDelegate.swift
//  Example
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import FolioReaderKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        URLProtocol.registerClass(MockURLProtocol.self)
        return true
    }
}

final class MockURLProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        print(request)
        if let url = request.url, url.absoluteString == "file:///localHost/Styles/style.css" {
            return true
        }
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        print("start loading: \(request.url)")
        //do nothing
//        self.client?.urlProtocol(self, didLoad: Data())
//        client?.urlProtocol(self, didReceive: URLResponse(url: request.url!, mimeType: nil, expectedContentLength: -1, textEncodingName: nil), cacheStoragePolicy: .allowed)
        client?.urlProtocol(self, didLoad: cssString.data(using: .utf8)!)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        //do nothing
    }
    
}


let cssString =
"""
h1, h2 {
margin-bottom: 1em;
text-align: center;
}

p {
margin-top: 0.5em;
margin-bottom: 0.5em;
text-align: justify;
}

p+p {
text-indent: 1em;
}

hr {
margin-left: 5%;
width: 90%;
text-align: center;
}

a {
text-decoration: none;
font-weight: bold;
}

blockquote {
margin-left: 1em;
margin-right: 1em;
margin-bottom: 2em;
font-style: italic;
}

blockquote p {
text-indent: 0em;
}

/* cover */
body.cover {
margin: 0em;
padding: 0em;
text-align: center;
width: 100%;
max-width: 100%;
}
img.cover {
margin: 0em;
padding: 0em;
width: 100%;
max-width: 100%;
}

/* titles */
p.titleCopyright {
text-align: center;
text-indent: 0em;
font-size: 85%;
}
p.titleNarrator {
text-align: center;
text-indent: 0em;
font-size: 125%;
margin-top: 1em;
margin-bottom: 2em;
}
h1.titleBookTitle {
text-align: center;
text-indent: 0em;
font-size: 175%;
font-variant: small-caps;
}
h1.titleStoryTitle {
text-align: center;
text-indent: 0em;
font-size: 150%;
font-variant: small-caps;
}
p.titleAuthor {
text-align: center;
text-indent: 0em;
font-size: 125%;
margin-top: 1em;
margin-bottom: 2em;
}
div.titleReadBeyond {
text-align: center;
text-indent: 0em;
margin-top: 6em;
}
img.titleReadBeyond {
margin: 0em;
padding: 0em;
max-width: 100%;
}
div.endReadBeyond {
text-align: center;
text-indent: 0em;
margin-top: 6em;
margin-bottom: 3em;
}
p.titleNormal {
text-align: center;
text-indent: 0em;
margin-top: 2em;
}
p.end {
text-align: center;
text-indent: 0em;
margin-top: 1em;
}

/* colophon */
p.colophon {
margin-top: 1em;
margin-left: 1em;
text-indent: 0em;
text-align: justify;
}
p.series {
margin-top: 1em;
margin-left: 1em;
text-indent: 0em;
text-align: center;
}
hr.colophon {
margin-top: 2em;
margin-bottom: 2em;
visibility: hidden;
}
span.aut {
font-style: italic;
}
span.tit {
font-variant: small-caps;
}
span.pub {
font-weight: bold;
}
span.bkp {
font-weight: bold;
}
span.ser {
font-weight: bold;
}
hr.colophon2 {
margin-left: 1em;
margin-top: 2em;
visibility: hidden;
}
div.contacts {
margin-left: 1em;
border-left: 5px solid grey;
page-break-inside: avoid;
font-size: 0.8em;
}
p.colophonContacts {
margin-top: 1em;
margin-left: 1em;
text-indent: 0em;
text-align: justify;
}
a.colophon {
margin-left: 10px;
margin-right: 10px;
vertical-align: middle;
}
img.colophon {
vertical-align: middle;
}
p.signature {
text-indent: 0em;
text-align: left;
margin-top: 2em;
}

/* playlist */
h1.playlist {
margin-top: 1em;
margin-bottom: 1em;
font-variant: small-caps;
}
div.playlist {
page-break-inside: avoid;
}
p.playlistHelp {
text-align: center;
}
table.playlist {
margin-left: 5%;
width: 90%;
text-align: center;
border-collapse: separate;
border-spacing: 0 0.5em;
}
tr.playlist {
vertical-align: middle;
}
td.playlist {
text-align: left;
}
div.playlist {
page-break-inside: avoid;
}
p.playlist {
margin-top: 0em;
margin-bottom: 0em;
margin-left: 0em;
text-indent: 0em;
text-align: left;
}
audio.playlist {
padding-left: 5%;
padding-right: 5%;
padding-top: 0.5em;
padding-bottom: 1.5em;
width: 90%;
}
span.trackNumber {
font-weight: bold;
}
span.trackTitle {
font-weight: bold;
}
span.trackDuration {
}

/* Audio */
audio {
width: 100%;
text-align: center;
}
div.audio {
margin-left: 5%;
width: 90%;
text-align: center;
page-break-inside: avoid;
}
p.audioError {
text-align: center;
text-indent: 0em;
margin-top: 0em;
margin-bottom: 0em;
}

/* chapter */
p.navBar {
text-indent: 0em;
text-align: center;
}
h2.sectionTitle {
text-align: center;
text-indent: 0em;
font-size: 125%;
}
p.separator {
text-align: center;
text-indent: 0em;
margin-top: 1em;
margin-bottom: 1em;
}
hr.separator {
margin-top: 1em;
margin-bottom: 1em;
visibility: hidden;
}

/* toc */
body.xhtmltoc {
}
div.xhtmltoc {
margin-left: 1em;
}
nav.xhtmltoc {
margin-left: 1em;
}
nav.xhtmltocHidden {
margin-left: 1em;
visibility: hidden;
}
h1.xhtmltoc {
margin-top: 1em;
margin-bottom: 1em;
padding: 0em;
text-align: left;
font-variant: small-caps;
}
ul.xhtmltoc {
margin-left: 0em;
padding: 0em;
text-align: left;
list-style-type: none;
}
ol.xhtmltoc {
margin-left: 0em;
padding: 0em;
text-align: left;
list-style-type: none;
}
li.xhtmltoc {
margin-top: 0.75em;
margin-bottom: 0.75em;
}
p.xhtmltoc {
margin-left: 0em;
padding: 0em;
text-align: left;
text-indent: 0em;
margin-top: 0.75em;
margin-bottom: 0.75em;
}
ul.xhtmltoc2 {
margin-left: 1em;
padding: 0em;
text-align: left;
list-style-type: none;
}
ol.xhtmltoc2 {
margin-left: 1em;
padding: 0em;
text-align: left;
list-style-type: none;
}
li.xhtmltoc2 {
margin-top: 0.75em;
margin-bottom: 0.75em;
}
p.xhtmltoc2 {
margin-left: 1em;
padding: 0em;
text-align: left;
text-indent: 0em;
margin-top: 0.75em;
margin-bottom: 0.75em;
}
a.xhtmltoc {
}

/* Media Overlay highlight color: yellow */
.-epub-media-overlay-active {
background-color: #FFFF00;
}
.rbActiveFragment {
background-color: #FFFF99;
-webkit-transition: background 0.25s;
}
.rbPausedFragment {
background-color: #99FF99;
-webkit-transition: background 0.25s;
}

"""
