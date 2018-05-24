//
//  FolioReaderChapterListCell.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 07/05/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderChapterListCell: UITableViewCell {
    var indexLabel: UILabel?
    private var accessory: UIView?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.indexLabel = UILabel()
    }

    func setup(withConfiguration readerConfig: FolioReaderConfig) {

        self.indexLabel?.lineBreakMode = .byWordWrapping
        self.indexLabel?.numberOfLines = 0
        self.indexLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.indexLabel?.font = UIFont(name: "Avenir-Light", size: 17)
        self.indexLabel?.textColor = readerConfig.menuTextColor

        if let label = self.indexLabel {
            self.contentView.addSubview(label)

            // Configure cell contraints
            var constraints = [NSLayoutConstraint]()
            let views = ["label": label]

            NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[label]-15-|", options: [], metrics: nil, views: views).forEach {
                constraints.append($0 as NSLayoutConstraint)
            }

            NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[label]-16-|", options: [], metrics: nil, views: views).forEach {
                constraints.append($0 as NSLayoutConstraint)
            }

            self.contentView.addConstraints(constraints)
        }
    }
    
    func add(accessoryView: UIView) {
        self.accessory = accessoryView
        
        contentView.addSubview(accessoryView)
        
        let views = ["view": accessoryView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view]|",  options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // As the `setup` is called at each reuse, make sure the label is added only once to the view hierarchy.
        self.indexLabel?.removeFromSuperview()
        self.accessory?.removeFromSuperview()
    }
}
