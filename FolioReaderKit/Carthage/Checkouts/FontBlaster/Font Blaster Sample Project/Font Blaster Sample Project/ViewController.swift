//
//  ViewController.swift
//  FontBlasterSample
//
//  Created by Arthur Sabintsev on 5/5/15.
//  Copyright (c) 2015 Arthur Ariel Sabintsev. All rights reserved.
//

import UIKit
import FontBlaster

class ViewController: UIViewController {

    @IBOutlet weak var boldLabel: UILabel!
    @IBOutlet weak var boldItalicLabel: UILabel!
    @IBOutlet weak var extraBoldLabel: UILabel!
    @IBOutlet weak var extraBoldItaliclabel: UILabel!
    @IBOutlet weak var italicLabel: UILabel!
    @IBOutlet weak var lightLabel: UILabel!
    @IBOutlet weak var lightItalicLabel: UILabel!
    @IBOutlet weak var regularLabel: UILabel!
    @IBOutlet weak var semiboldLabel: UILabel!
    @IBOutlet weak var semiboldItalicLabel: UILabel!
    @IBOutlet weak var loadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFonts()
    }

    func setupFonts() {
        boldLabel.font = UIFont(name: "OpenSans-Bold", size: boldLabel.font.pointSize)
        boldItalicLabel.font = UIFont(name: "OpenSans-BoldItalic", size: boldItalicLabel.font.pointSize)
        extraBoldLabel.font = UIFont(name: "OpenSans-ExtraBold", size: extraBoldLabel.font.pointSize)
        extraBoldItaliclabel.font = UIFont(name: "OpenSans-ExtraBoldItalic", size: extraBoldItaliclabel.font.pointSize)
        italicLabel.font = UIFont(name: "OpenSans-Italic", size: italicLabel.font.pointSize)
        lightLabel.font = UIFont(name: "OpenSans-Light", size: lightLabel.font.pointSize)
        lightItalicLabel.font = UIFont(name: "OpenSans-LightItalic", size: lightItalicLabel.font.pointSize)
        regularLabel.font = UIFont(name: "OpenSans-Regular", size: regularLabel.font.pointSize)
        semiboldLabel.font = UIFont(name: "OpenSans-Semibold", size: semiboldLabel.font.pointSize)
        semiboldItalicLabel.font = UIFont(name: "OpenSans-SemiboldItalic", size: semiboldItalicLabel.font.pointSize)
    }
    
    @IBAction func loadButtonAction(sender: UIButton) {
        FontBlaster.debugEnabled = true
        FontBlaster.blast { (fonts) -> Void in
            print("Loaded Fonts", fonts)
        }
        setupFonts()
    }
    
}

