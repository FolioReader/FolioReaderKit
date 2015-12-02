//
//  FolioReaderSidePanelCell.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 07/05/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderSidePanelCell: UITableViewCell {
    var indexLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        indexLabel.frame = contentView.frame
        indexLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        contentView.addSubview(indexLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
