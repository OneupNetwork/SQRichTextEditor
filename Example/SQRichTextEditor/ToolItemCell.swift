//
//  ToolBarItemCell.swift
//  SQRichTextEditor_Example
//
//  Created by  Jesse on 2019/12/13.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SQRichTextEditor

class ToolItemCell: UICollectionViewCell {
    
    lazy var textLabel: UILabel = {
        let _textLabel = UILabel()
        _textLabel.translatesAutoresizingMaskIntoConstraints = false
        return _textLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(textLabel)
        textLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(option: ToolOptionType, attribute: SQTextAttribute) {
        //Format
        var isActive = false
        switch option {
        case .bold:
            isActive = attribute.format.hasBold
        case .italic:
            isActive = attribute.format.hasItalic
        case .strikethrough:
            isActive = attribute.format.hasStrikethrough
        case .underline:
            isActive = attribute.format.hasUnderline
        default:
            break
        }
        textLabel.text = option.description
        textLabel.font = isActive ? ToolItemCellSettings.activeFont : ToolItemCellSettings.normalfont
        textLabel.textColor = isActive ? ToolItemCellSettings.activeColor : ToolItemCellSettings.normalColor
        
        //TextInfo
        switch option {
        case .setTextSize:
            if let size = attribute.textInfo.size {
                textLabel.text = "Font Size(\(size)px)"
            }
            
        case .setTextColor:
            if let color = attribute.textInfo.color {
                textLabel.textColor = color
            }
            
        case .setTextBackgroundColor:
            if let color = attribute.textInfo.backgroundColor {
                textLabel.textColor = color
            }
            
        default:
            break
        }
    }
}
