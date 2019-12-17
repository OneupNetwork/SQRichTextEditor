//
//  SQAttributedText.swift
//  Pods-SQRichTextEditor_Example
//
//  Created by  Jesse on 2019/12/12.
//

import Foundation

public class SQTextAttribute: NSObject {
    public var format = SQTextAttributeFormat()
    public var fontInfo = SQTextAttributeFontInfo()
}

public struct SQTextAttributeFormat: Codable {
    public var hasBold = false
    public var hasItalic = false
    public var hasStrikethrough = false
    public var hasUnderline = false
    public var hasLink = false
    
    enum CodingKeys: String, CodingKey {
        case hasBold = "bold"
        case hasItalic = "italic"
        case hasStrikethrough = "strikethrough"
        case hasUnderline = "underline"
        case hasLink = "link"
    }
}

public struct SQTextAttributeFontInfo: Codable {
    private var textColor: String?
    private var textBackgroundColor: String?
    public var size: Int?
    
    public var color: UIColor? {
        guard let textColor = textColor else { return nil }
        return Helper.hexToRGBColor(hex: textColor)
    }
    
    public var backgroundColor: UIColor? {
        guard let textBackgroundColor = textBackgroundColor else { return nil }
        return Helper.hexToRGBColor(hex: textBackgroundColor)
    }
    
    enum CodingKeys: String, CodingKey {
        case textColor = "color"
        case textBackgroundColor = "backgroundColor"
        case size = "size"
    }
    
    init(textHexColor: String? = nil,
         textBackgroundHexColor: String? = nil,
         size: Int? = nil) {
        self.textColor = textHexColor
        self.textBackgroundColor = textBackgroundHexColor
        self.size = size
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        textColor = try? container.decode(String.self, forKey: .textColor)

        textBackgroundColor = try? container.decode(String.self, forKey: .textBackgroundColor)

        if let value = try? container.decode(String.self, forKey: .size) {
            size = Int(value)
        }
    }
}
