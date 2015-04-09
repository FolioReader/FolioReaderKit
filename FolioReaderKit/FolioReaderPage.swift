//
//  FolioReaderPage.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 09/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import WebKit

protocol FolioReaderPageDelegate {
    func pageDidFinishLoad()
}

class FolioReaderPage: UIView {
    
    var delegate: FolioReaderPageDelegate!
    var webView: AnyObject!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let demoStr = "<?xml version=\"1.0\" encoding=\"utf-8\"?> <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\"> <head> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, user-scalable=no\"> <meta name=\"generator\" content= \"HTML Tidy for FreeBSD (vers 7 December 2008), see www.w3.org\" /> <title>Romeo and Juliet</title> <style>* { padding: 0; margin: 0; outline: none; list-style: none; border: 0 none; } /* Typography & Colors */ body { font: 19px/1.6em helvetica, sans-serif; padding: 40px 30px; color: #383737; } .content-title { font: 35px/1.3em helvetica, sans-serif; margin-bottom: 35px; color: black; } .author { font: 20px/1.5em helvetica, sans-serif; margin-bottom: 25px; color: lightgray; } b, strong { font-family: helvetica, sans-serif; } i, em { font-family: helvetica, sans-serif; } a { color: #004270; } .wp-caption p.wp-caption-text { color: #888; margin: 0 5px; font-size: 14px; } .gallery-caption { font-size: 14px; line-height: 1.3; } /* Layout */ .alignleft { float: left; } img.alignleft { padding: 5px; margin-right: 20px; display: inline; background: #f1f1f1; } p { padding-top: 0.8em; padding-bottom: 0.6em; } .gallery-icon { margin: 10px 0; } .wp-caption.alignleft { margin: 1em 20px 0 0; } .wp-caption { background: #f1f1f1; line-height: 18px; margin-bottom: 20px; max-width: 100% !important; padding-top: 5px; text-align: center; }</style> <meta http-equiv=\"Content-Type\" content= \"application/xhtml+xml; charset=utf-8\" /> </head> <body> <div class=\"body\"> <div id=\"chapter_3521\" class=\"chapter\"> <h2><span class=\"chapterHeader\"><span class= \"translation\">Chapter</span> <span class= \"count\">12</span></span></h2> <p>&#160;</p> <div class=\"text\"> <p>In the evening Andrew and Pierre got into the open carriage and drove to Bald Hills. Prince Andrew, glancing at Pierre, broke the silence now and then with remarks which showed that he was in a good temper.</p> <p>Pointing to the fields, he spoke of the improvements he was making in his husbandry.</p> <p>Pierre remained gloomily silent, answering in monosyllables and apparently immersed in his own thoughts.</p> <p>He was thinking that Prince Andrew was unhappy, had gone astray, did not see the true light, and that he, Pierre, ought to aid, enlighten, and raise him. But as soon as he thought of what he should say, he felt that Prince Andrew with one word, one argument, would upset all his teaching, and he shrank from beginning, afraid of exposing to possible ridicule what to him was precious and sacred.</p> <p>\"No, but why do you think so?\" Pierre suddenly began, lowering his head and looking like a bull about to charge, \"why do you think so? You should not think so.\"</p> <p>\"Think? What about?\" asked Prince Andrew with surprise.</p> <p>\"About life, about man's destiny. It can't be so. I myself thought like that, and do you know what saved me? Freemasonry! No, don't smile. Freemasonry is not a religious ceremonial sect, as I thought it was: Freemasonry is the best expression of the best, the eternal, aspects of humanity.\"</p> <p>And he began to explain Freemasonry as he understood it to Prince Andrew. He said that Freemasonry is the teaching of Christianity freed from the bonds of State and Church, a teaching of equality, brotherhood, and love.</p> <p>\"Only our holy brotherhood has the real meaning of life, all the rest is a dream,\" said Pierre. \"Understand, my dear fellow, that outside this union all is filled with deceit and falsehood and I agree with you that nothing is left for an intelligent and good man but to live out his life, like you, merely trying not to harm others. But make our fundamental convictions your own, join our brotherhood, give yourself up to us, let yourself be guided, and you will at once feel yourself, as I have felt myself, a part of that vast invisible chain the beginning of which is hidden in heaven,\" said Pierre.</p> <p>Prince Andrew, looking straight in front of him, listened in silence to Pierre's words. More than once, when the noise of the wheels prevented his catching what Pierre said, he asked him to repeat it, and by the peculiar glow that came into Prince Andrew's eyes and by his silence, Pierre saw that his words were not in vain and that Prince Andrew would not interrupt him or laugh at what he said.</p> <p>They reached a river that had overflowed its banks and which they had to cross by ferry. While the carriage and horses were being placed on it, they also stepped on the raft.</p> <p>Prince Andrew, leaning his arms on the raft railing, gazed silently at the flooding waters glittering in the setting sun.</p> <p>\"Well, what do you think about it?\" Pierre asked. \"Why are you silent?\"</p> <p>\"What do I think about it? I am listening to you. It's all very well… . You say: join our brotherhood and we will show you the aim of life, the destiny of man, and the laws which govern the world. But who are we? Men. How is it you know everything? Why do I alone not see what you see? You see a reign of goodness and truth on earth, but I don't see it.\"</p> <p>Pierre interrupted him.</p> <p>\"Do you believe in a future life?\" he asked.</p> <p>\"A future life?\" Prince Andrew repeated, but Pierre, giving him no time to reply, took the repetition for a denial, the more readily as he knew Prince Andrew's former atheistic convictions.</p> <p>\"You say you can't see a reign of goodness and truth on earth. Nor could I, and it cannot be seen if one looks on our life here as the end of everything. On earth, here on this earth\" (Pierre pointed to the fields), \"there is no truth, all is false and evil; but in the universe, in the whole universe there is a kingdom of truth, and we who are now the children of earth are—eternally—children of the whole universe. Don't I feel in my soul that I am part of this vast harmonious whole? Don't I feel that I form one link, one step, between the lower and higher beings, in this vast harmonious multitude of beings in whom the Deity—the Supreme Power if you prefer the term—is manifest? If I see, clearly see, that ladder leading from plant to man, why should I suppose it breaks off at me and does not go farther and farther? I feel that I cannot vanish, since nothing vanishes in this world, but that I shall always exist and always have existed. I feel that beyond me and above me there are spirits, and that in this world there is truth.\"</p> <p>\"Yes, that is Herder's theory,\" said Prince Andrew, \"but it is not that which can convince me, dear friend—life and death are what convince. What convinces is when one sees a being dear to one, bound up with one's own life, before whom one was to blame and had hoped to make it right\" (Prince Andrew's voice trembled and he turned away), \"and suddenly that being is seized with pain, suffers, and ceases to exist… . Why? It cannot be that there is no answer. And I believe there is… . That's what convinces, that is what has convinced me,\" said Prince Andrew.</p> <p>\"Yes, yes, of course,\" said Pierre, \"isn't that what I'm saying?\"</p> <p>\"No. All I say is that it is not argument that convinces me of the necessity of a future life, but this: when you go hand in hand with someone and all at once that person vanishes there, into nowhere, and you yourself are left facing that abyss, and look in. And I have looked in… .\"</p> <p>\"Well, that's it then! You know that there is a there and there is a Someone? There is the future life. The Someone is—God.\"</p> <p>Prince Andrew did not reply. The carriage and horses had long since been taken off, onto the farther bank, and reharnessed. The sun had sunk half below the horizon and an evening frost was starring the puddles near the ferry, but Pierre and Andrew, to the astonishment of the footmen, coachmen, and ferrymen, still stood on the raft and talked.</p> <p>\"If there is a God and future life, there is truth and good, and man's highest happiness consists in striving to attain them. We must live, we must love, and we must believe that we live not only today on this scrap of earth, but have lived and shall live forever, there, in the Whole,\" said Pierre, and he pointed to the sky.</p> <p>Prince Andrew stood leaning on the railing of the raft listening to Pierre, and he gazed with his eyes fixed on the red reflection of the sun gleaming on the blue waters. There was perfect stillness. Pierre became silent. The raft had long since stopped and only the waves of the current beat softly against it below. Prince Andrew felt as if the sound of the waves kept up a refrain to Pierre's words, whispering:</p> <p>\"It is true, believe it.\"</p> <p>He sighed, and glanced with a radiant, childlike, tender look at Pierre's face, flushed and rapturous, but yet shy before his superior friend.</p> <p>\"Yes, if it only were so!\" said Prince Andrew. \"However, it is time to get on,\" he added, and, stepping off the raft, he looked up at the sky to which Pierre had pointed, and for the first time since Austerlitz saw that high, everlasting sky he had seen while lying on that battlefield; and something that had long been slumbering, something that was best within him, suddenly awoke, joyful and youthful, in his soul. It vanished as soon as he returned to the customary conditions of his life, but he knew that this feeling which he did not know how to develop existed within him. His meeting with Pierre formed an epoch in Prince Andrew's life. Though outwardly he continued to live in the same old way, inwardly he began a new life.</p> </div> </div> </div> </body> </html>"
        
        if (NSClassFromString("WKWebView") != nil) {
            let config = WKWebViewConfiguration()
            webView = WKWebView(frame: self.bounds, configuration: config)
            (webView as! WKWebView).backgroundColor = getRandomColor()
            (webView as! WKWebView).autoresizingMask = .FlexibleWidth | .FlexibleHeight
            self.addSubview(webView as! WKWebView)
        
            var castWebView = (webView as! WKWebView)
            castWebView.loadHTMLString(demoStr, baseURL: nil)
        }
//        else {
//            webView = UIWebView(frame: self.bounds)
//            (webView as! UIWebView).autoresizingMask = .FlexibleWidth | .FlexibleHeight
//            self.addSubview(webView as! UIWebView)
//        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getRandomColor() -> UIColor {
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func pageDidFinishLoad() {
    
    }
}
