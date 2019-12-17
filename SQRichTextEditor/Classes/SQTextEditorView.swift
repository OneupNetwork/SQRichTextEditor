//
//  SQTextEditorView.swift
//  SQRichTextEditor
//
//  Created by  Jesse on 2019/12/10.
//

import UIKit
import WebKit

@objc public protocol SQTextEditorDelegate: class {
    
    //Called when the editor components is ready.
    @objc optional func editorDidLoad(_ editor: SQTextEditorView)
    
    //Called when the user selected some text or moved the cursor to a different position.
    @objc optional func editor(_ editor: SQTextEditorView,
                               selectedTextAttributeDidChange attribute: SQTextAttribute)
    
    //Called when the user inserted, deleted or changed the style of some text.
    @objc optional func editor(_ editor: SQTextEditorView,
                               contentHeightDidChange height: Int)
}

public class SQTextEditorView: UIView {
    
    public weak var delegate: SQTextEditorDelegate?
    
    public lazy var selectedTextAttribute = SQTextAttribute()
    
    private enum JSFunctionType {
        case getHTML
        case insertHTML(html: String)
        case setSelection(
            startElementId: String,
            startIndex: Int,
            endElementId: String,
            endIndex: Int)
        case getSelectedText
        case setFormat(type: RichTextFormatType)
        case removeFormat(type: RichTextFormatType)
        case setFontColor(hex: String)
        case setFontSize(size: Int)
        case insertImage(url: String)
        case makeLink(url: String)
        case removeLink
        case clear
        
        var name: String {
            switch self {
            case .getHTML:
                return "getHTML()"
                
            case .insertHTML(let html):
                return "insertHTML('\(html)')"
                
            case .setSelection(let sId, let s, let eId, let e):
                return "setTextSelection('\(sId)','\(s)','\(eId)','\(e)')"
                
            case .getSelectedText:
                return "getSelectedText()"
                
            case .setFormat(let type):
                return "setFormat('\(type.keyName)')"
                
            case .removeFormat(let type):
                return "removeFormat('\(type.keyName)')"
                
            case .setFontColor(let hex):
                return "setFontColor('\(hex)')"
                
            case .setFontSize(let size):
                return "setFontSize('\(size)')"
                
            case .insertImage(let url):
                return "insertImage('\(url)')"
                
            case .makeLink(let url):
                return "makeLink('\(url)')"
                
            case .removeLink:
                return "removeLink()"
                
            case .clear:
                return "clear()"
            }
        }
    }
    
    private enum JSMessageName: String, CaseIterable {
        case contentHeight = "contentHeight"
        case fontInfo = "fontInfo"
        case format = "format"
    }
    
    private enum RichTextFormatType {
        case bold
        case italic
        case strikethrough
        case underline
        
        var keyName: String {
            switch self {
            case .bold:
                return "bold"
            case .italic:
                return "italic"
            case .strikethrough:
                return "strikethrough"
            case .underline:
                return "underline"
            }
        }
    }
    
    private lazy var webView : WKWebView = {
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.minimumFontSize = 10
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.processPool = WKProcessPool()
        config.userContentController = WKUserContentController()
        
        JSMessageName.allCases.forEach {
            config.userContentController.add(self, name: $0.rawValue)
        }
        
        let _webView = WKWebView(frame: .zero, configuration: config)
        _webView.translatesAutoresizingMaskIntoConstraints = false
        _webView.navigationDelegate = self
        _webView.allowsLinkPreview = false
        return _webView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupEditor()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupEditor()
    }
    
    deinit {
        JSMessageName.allCases.forEach {
            webView
                .configuration
                .userContentController
                .removeScriptMessageHandler(forName: $0.rawValue)
        }
    }
    
    //MARK: - Private Methods
    
    private func setupUI() {
        self.addSubview(webView)
        
        webView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    private func setupEditor() {
        if let path = Bundle(for: SQTextEditorView.self)
            .path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: path)
            
            let request = URLRequest.init(url: url,
                                          cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                          timeoutInterval: 5.0)
            webView.load(request)
        }
    }
    
    private func setFormat(_ type: RichTextFormatType,
                           completion: ((_ error: Error?) -> ())?) {
        webView.evaluateJavaScript(JSFunctionType.setFormat(type: type).name,
                                   completionHandler: { (_, error) in
                                    completion?(error)
        })
    }
    
    private func removeFormat(_ type: RichTextFormatType,
                              completion: ((_ error: Error?) -> ())?) {
        webView.evaluateJavaScript(JSFunctionType.removeFormat(type: type).name,
                                   completionHandler: { (_, error) in
                                    completion?(error)
        })
    }
    
    //MARK: - Public Methods
    
    /**
     Returns the HTML value of the editor in its current state.
     
     - Parameter html: HTML String.
     */
    public func getHTML(completion: @escaping (_ html: String?) -> ()) {
        webView.evaluateJavaScript(JSFunctionType.getHTML.name, completionHandler: { (value, error) in
            completion(value as? String)
        })
    }
    
    /**
     Inserts an HTML fragment at the current cursor location, or replaces the selection if selected. The value supplied should not contain <body> tags or anything outside of that.
     
     - Parameter html: The html String to insert.
     - Parameter completion: The block to execute after the operation finishes. This takes an error of script evaluation as a parameter. You may specify nil for this parameter.
     */
    public func insertHTML(_ html: String,
                           completion: ((_ error: Error?) -> ())? = nil) {
        webView.evaluateJavaScript(JSFunctionType.insertHTML(html: html).name, completionHandler: { (_, error) in
            completion?(error)
        })
    }
    
    /**
     Changes the current selection position. The selected range will be selected from the first node that type equal 'TEXT_NODE' under the input element id
     
     - Parameter startElementId: The element ID for range of start selection
     - Parameter startIndex: Sets the starting position of the element that the id you specified.
     - Parameter endElementId: The element ID for range of end selection
     - Parameter endIndex: Sets the ending position of the element that the id you specified.
     - Parameter completion: The block to execute after the operation finishes. This takes an error of script evaluation as a parameter. You may specify nil for this parameter.
     
     HTML:
     ```
     <div id="a">123<br></div>
     <div id="b">456<br></div>
     ```
     
     The selected text is `12`
     ```
     setSelection(startElementId: a, startIndex: 0, endElementId: a, endIndex: 2)
     
     ```
     
     The selected text is `34`
     ```
     setSelection(startElementId: a, startIndex: 2, endElementId: b, endIndex: 1)
     
     ```
     */
    public func setTextSelection(startElementId: String,
                             startIndex: Int,
                             endElementId: String,
                             endIndex: Int,
                             completion: ((_ error: Error?) -> ())? = nil) {
        webView.evaluateJavaScript(JSFunctionType.setSelection(startElementId: startElementId,
                                                               startIndex: startIndex,
                                                               endElementId: endElementId,
                                                               endIndex: endIndex).name,
                                   completionHandler: { (_, error) in
                                    completion?(error)
        })
        
    }
    
    /**
     Returns the text currently selected in the editor.
     
     - Parameter text: Selected text.
     */
    public func getSelectedText(completion: @escaping (_ text: String?) -> ()) {
        webView.evaluateJavaScript(JSFunctionType.getSelectedText.name,
                                   completionHandler: { (value, error) in
                                    completion(value as? String)
        })
    }
    
    /**
     Makes any non-bold currently selected text bold (by wrapping it in a 'b' tag),
     otherwise removes any bold formatting from the selected text.
     */
    public func bold(completion: ((_ error: Error?) -> ())? = nil) {
        selectedTextAttribute.format.hasBold ?
            removeFormat(.bold, completion: completion) :
            setFormat(.bold, completion: completion)
    }
    
    /**
     Makes any non-italic currently selected text italic (by wrapping it in an 'i' tag),
     otherwise removes any italic formatting from the selected text.
     */
    public func italic(completion: ((_ error: Error?) -> ())? = nil) {
        selectedTextAttribute.format.hasItalic ?
            removeFormat(.italic, completion: completion) :
            setFormat(.italic, completion: completion)
    }
    
    /**
     Makes any non-underlined currently selected text underlined (by wrapping it in a 'u' tag),
     otherwise removes any underline formatting from the selected text.
     */
    public func underline(completion: ((_ error: Error?) -> ())? = nil) {
        selectedTextAttribute.format.hasUnderline ?
            removeFormat(.underline, completion: completion) :
            setFormat(.underline, completion: completion)
    }
    
    /**
     Makes any non-strikethrough currently selected text underlined (by wrapping it in a 'del' tag),
     otherwise removes any strikethrough formatting from the selected text.
     */
    public func strikethrough(completion: ((_ error: Error?) -> ())? = nil) {
        selectedTextAttribute.format.hasStrikethrough ?
            removeFormat(.strikethrough, completion: completion) :
            setFormat(.strikethrough, completion: completion)
    }
    
    /**
    Sets the colour of the selected text.
    
    - Parameter color: The colour to set.
    */
    public func setFont(color: UIColor, completion: ((_ error: Error?) -> ())? = nil) {
        let hex = Helper.rgbColorToHex(color: color)
        
        webView.evaluateJavaScript(JSFunctionType.setFontColor(hex: hex).name,
        completionHandler: { (_, error) in
         completion?(error)
        })
    }
    
    /**
     Sets the font size for the selected text.
    
    - Parameter size: A size to set. The absolute length units will be 'px'
    */
    public func setFont(size: Int, completion: ((_ error: Error?) -> ())? = nil) {
        webView.evaluateJavaScript(JSFunctionType.setFontSize(size: size).name,
        completionHandler: { (_, error) in
         completion?(error)
        })
    }
    
    /**
    Inserts an image at the current cursor location.
    
    - Parameter url: The source path for the image.
    */
    public func insertImage(url: String, completion: ((_ error: Error?) -> ())? = nil) {
        webView.evaluateJavaScript(JSFunctionType.insertImage(url: url).name,
        completionHandler: { (_, error) in
         completion?(error)
        })
    }
    
    /**
    Makes the currently selected text a link. If no text is selected, the URL or email will be inserted as text at the current cursor point and made into a link.
    
    - Parameter url: The url or email to link to.
    */
    public func makeLink(url: String, completion: ((_ error: Error?) -> ())? = nil) {
        webView.evaluateJavaScript(JSFunctionType.makeLink(url: url).name,
        completionHandler: { (_, error) in
         completion?(error)
        })
    }
    
    /**
    Removes any link that is currently at least partially selected.
    */
    public func removeLink(completion: ((_ error: Error?) -> ())? = nil) {
        webView.evaluateJavaScript(JSFunctionType.removeLink.name,
        completionHandler: { (_, error) in
         completion?(error)
        })
    }
    
    /**
    Clear Editor's content. Method removes all Blocks and inserts new initial empty Block
     `<div><br></div>`
    */
    public func clear(completion: ((_ error: Error?) -> ())? = nil) {
        webView.evaluateJavaScript(JSFunctionType.clear.name,
        completionHandler: { (_, error) in
         completion?(error)
        })
    }
}

extension SQTextEditorView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.delegate?.editorDidLoad?(self)
    }
}

extension SQTextEditorView: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {
        if let name = JSMessageName(rawValue: message.name) {
            switch name {
            case .contentHeight:
                if let value = message.body as? NSNumber {
                    delegate?.editor?(self, contentHeightDidChange: value.intValue)
                }

            case .fontInfo:
                if let dict = message.body as? [String: Any],
                    let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
                    let fontInto = try? JSONDecoder().decode(SQTextAttributeFontInfo.self, from: data) {
                    selectedTextAttribute.fontInfo = fontInto
                    delegate?.editor?(self, selectedTextAttributeDidChange: selectedTextAttribute)
                }
                
            case .format:
                if let dict = message.body as? [String: Bool],
                    let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
                    let format = try? JSONDecoder().decode(SQTextAttributeFormat.self, from: data) {
                    selectedTextAttribute.format = format
                    delegate?.editor?(self, selectedTextAttributeDidChange: selectedTextAttribute)
                }
            }
        }
    }
}

