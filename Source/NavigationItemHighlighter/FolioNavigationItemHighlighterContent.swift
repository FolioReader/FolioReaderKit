//
//  NavigationItemContent.swift
//  SberbankVS
//
//  Created by Dmitry Rozov on 11/07/2018.
//  Copyright © 2018 Mobile Up. All rights reserved.
//

import UIKit

internal struct FolioNavigationItemHighlighterContent {
    let data: ContentData
    let item: UIBarButtonItem
    let side: BarButtonItemSide
    
    var itemRect: CGRect? {
        if let view = (item.value(forKey: "view") as? UIView)?.subviews.first {
            return view.superview?.convert(view.frame, to: nil)
        }
        return nil
    }
    
    enum ContentData {
        case chaptersList
        case fontOptions
        
        var title: String {
            switch self {
            case .chaptersList:
                return "Открывайте оглавление"
            case .fontOptions:
                return "Настройте шрифт"
            }
        }
        
        var description: String? {
            switch self {
            case .chaptersList:
                return "чтобы найти интересующую вас тему"
            case .fontOptions:
                return "и другие параметры чтения"
            }
        }
    }
    
    enum BarButtonItemSide {
        case right, left
    }
}

var highlightShown: Bool {
    get {
        return UserDefaults.standard.bool(forKey: "highlightShown")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "highlightShown")
        UserDefaults.standard.synchronize()
    }
}
