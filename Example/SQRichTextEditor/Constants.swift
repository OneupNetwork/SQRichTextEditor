//
//  Constants.swift
//  SQRichTextEditor_Example
//
//  Created by  Jesse on 2019/12/13.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SQRichTextEditor

enum ToolItemCellSettings {
    static let id = "toolItemCell"
    
    static let normalfont = UIFont.systemFont(ofSize: 14, weight: .light)
    static let activeFont = UIFont.systemFont(ofSize: 14, weight: .bold)
    
    static let normalColor = UIColor.black
    static let activeColor = UIColor.blue
    
    static let height: CGFloat = 35
}

enum ToolOptionType: Int, CustomStringConvertible, CaseIterable {
    case bold
    case italic
    case strikethrough
    case underline
    case clear
    case makeLink
    case removeLink
    case insertImage
    case setTextColor
    case setTextBackgroundColor
    case setTextSize
    case insertHTML
    case getHTML
    
    var description: String {
        switch self {
        case .bold:
            return "Bold"
        case .italic:
            return "Italic"
        case .strikethrough:
            return "Strikethrough"
        case .underline:
            return "Underline"
        case .clear:
            return "Clear"
        case .makeLink:
            return "Make Link"
        case .removeLink:
            return "Remove Link"
        case .insertImage:
            return "Insert Image"
        case .setTextColor:
            return "Text Color"
        case .setTextBackgroundColor:
            return "Text Background Color"
        case .setTextSize:
            return "Text Size(default)"
        case .insertHTML:
            return "Insert HTML"
        case .getHTML:
            return "Get HTML"
        }
    }
}
