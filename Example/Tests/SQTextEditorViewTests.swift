import XCTest
import SQRichTextEditor
 
class SQTextEditorViewTests: XCTestCase, SQTextEditorDelegate {
    
    private let timeout: TimeInterval = 180
    private var editor: SQTextEditorView!
    private var editorDidLoadHandler: (() -> ())?
    private let logoImgUrl = "https://i.imgur.com/tSwpCeL.png"
    
    private func makeTestHTML(id: String? = nil, value: String? = nil) -> String {
        let tag = id == nil ? "<div>" : "<div id=\"\(id!)\">"
        return "\(tag)\(value ?? "")<br></div>"
    }
    
    override func setUp() {
        super.setUp()
        
        editor = SQTextEditorView(frame: .zero)
        editor.delegate = self
        
        let exp = expectation(description: "\(#function)\(#line)")
        
        editorDidLoadHandler = {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    override func tearDown() {
        editor = nil
        
        super.tearDown()
    }
    
    func testGetHTML() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        editor.getHTML(completion: { html in
            
            XCTAssert(html == self.makeTestHTML())
            
            exp.fulfill()
        })
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testInsertHTML() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let testHtml = makeTestHTML(value: "test")
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.getHTML(completion: { html in
                XCTAssert(html == testHtml)
                exp.fulfill()
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSetSelectionInSameElementId() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let value = "test text"
        let tagId = "test"
        let testHtml = makeTestHTML(id: tagId, value: value)
        let startIndex = 0
        let endIndex = 2
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId,
                                         startIndex: startIndex,
                                         endElementId: tagId,
                                         endIndex: endIndex,
                                         completion: { error in
                                            XCTAssertNil(error)
                                            
                                            self.editor.getSelectedText { text in
                                                XCTAssert((text ?? "") == value.prefix(endIndex - startIndex))
                                                exp.fulfill()
                                            }
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSetSelectionCrossElementId() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId1 = "a"
        let tagId2 = "b"
        
        let testHtml = "<div id=\"\(tagId1)\">123</div><div id=\"\(tagId2)\">456</div>"
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId1, startIndex: 2, endElementId: tagId2, endIndex: 1, completion: { error in
                XCTAssertNil(error)
                
                self.editor.getSelectedText { text in
                    XCTAssert((text ?? "")
                        .replacingOccurrences(of: "\n", with: "")
                        .replacingOccurrences(of: " ", with: "")
                        == "34")
                    exp.fulfill()
                }
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testBold() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        
        let testHtml = "<div id=\"\(tagId)\">123</div>"
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId, startIndex: 0, endElementId: tagId, endIndex: 2, completion: { error in
                XCTAssertNil(error)
                
                self.editor.bold { error in
                    XCTAssertNil(error)
                    XCTAssert(self.editor.selectedTextAttribute.format.hasBold)
                    exp.fulfill()
                }
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRemoveBold() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        
        let testHtml = "<b id=\"\(tagId)\">123</b>"
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId, startIndex: 0, endElementId: tagId, endIndex: 2, completion: { error in
                XCTAssertNil(error)
                
                self.editor.bold { error in
                    XCTAssertNil(error)
                    XCTAssertFalse(self.editor.selectedTextAttribute.format.hasBold)
                    exp.fulfill()
                }
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testItalic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        
        let testHtml = "<div id=\"\(tagId)\">123</div>"
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId, startIndex: 0, endElementId: tagId, endIndex: 2, completion: { error in
                XCTAssertNil(error)
                
                self.editor.italic { error in
                    XCTAssertNil(error)
                    XCTAssert(self.editor.selectedTextAttribute.format.hasItalic)
                    exp.fulfill()
                }
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRemoveItalic() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        
        let testHtml = "<i id=\"\(tagId)\">123</i>"
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId, startIndex: 0, endElementId: tagId, endIndex: 2, completion: { error in
                XCTAssertNil(error)
                
                self.editor.italic { error in
                    XCTAssertNil(error)
                    XCTAssertFalse(self.editor.selectedTextAttribute.format.hasItalic)
                    exp.fulfill()
                }
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testUnderline() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        
        let testHtml = "<div id=\"\(tagId)\">123</div>"
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId, startIndex: 0, endElementId: tagId, endIndex: 2, completion: { error in
                XCTAssertNil(error)
                
                self.editor.underline { error in
                    XCTAssertNil(error)
                    XCTAssert(self.editor.selectedTextAttribute.format.hasUnderline)
                    exp.fulfill()
                }
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRemoveUnderline() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        
        let testHtml = "<u id=\"\(tagId)\">123</u>"
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId, startIndex: 0, endElementId: tagId, endIndex: 2, completion: { error in
                XCTAssertNil(error)
                
                self.editor.underline { error in
                    XCTAssertNil(error)
                    XCTAssertFalse(self.editor.selectedTextAttribute.format.hasUnderline)
                    exp.fulfill()
                }
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testStrikethrough() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        
        let testHtml = "<div id=\"\(tagId)\">123</div>"
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId, startIndex: 0, endElementId: tagId, endIndex: 2, completion: { error in
                XCTAssertNil(error)
                
                self.editor.strikethrough { error in
                    XCTAssertNil(error)
                    XCTAssert(self.editor.selectedTextAttribute.format.hasStrikethrough)
                    exp.fulfill()
                }
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRemoveStrikethrough() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        
        let testHtml = "<del id=\"\(tagId)\">123</del>"
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId, startIndex: 0, endElementId: tagId, endIndex: 2, completion: { error in
                XCTAssertNil(error)
                
                self.editor.strikethrough { error in
                    XCTAssertNil(error)
                    XCTAssertFalse(self.editor.selectedTextAttribute.format.hasStrikethrough)
                    exp.fulfill()
                }
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSetTextSize() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        
        let testHtml = "<div id=\"\(tagId)\">123</div>"
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId, startIndex: 0, endElementId: tagId, endIndex: 2, completion: { error in
                XCTAssertNil(error)
                
                let size = 25
                
                self.editor.setText(size: size, completion: { error in
                    XCTAssert(self.editor.selectedTextAttribute.textInfo.size == size)
                    exp.fulfill()
                })
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSetTextColor() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        let testHtml = makeTestHTML(id: tagId, value: "test")
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId,
                                         startIndex: 0,
                                         endElementId: tagId,
                                         endIndex: 2,
                                         completion: { error in
                XCTAssertNil(error)
                
                let color = UIColor.brown
                
                self.editor.setText(color: color, completion: { error in
                    XCTAssert(self.editor.selectedTextAttribute.textInfo.color == color)
                    exp.fulfill()
                })
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSetTextBackgroundColor() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        let testHtml = makeTestHTML(id: tagId, value: "test")
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId,
                                         startIndex: 0,
                                         endElementId: tagId,
                                         endIndex: 2,
                                         completion: { error in
                XCTAssertNil(error)
                
                let color = UIColor.brown
                
                self.editor.setText(backgroundColor: color, completion: { error in
                    XCTAssert(self.editor.selectedTextAttribute.textInfo.backgroundColor == color)
                    exp.fulfill()
                })
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testInsertImage() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        editor.insertImage(url: logoImgUrl, completion: { error in
            XCTAssertNil(error)
            
            self.editor.getHTML { html in
                XCTAssertNotNil(html)
                
                if let html = html {
                    XCTAssert(html == "<div><img src=\"\(self.logoImgUrl)\"><br></div>")
                }
                
                exp.fulfill()
            }
        })
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testMakeLink() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "logo"
        let value = "123"
        let testHtml = makeTestHTML(id: tagId, value: value)
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId,
                                         startIndex: 0,
                                         endElementId: tagId,
                                         endIndex: value.count,
                                         completion: { error in
                                            XCTAssertNil(error)
                                            
                                            self.editor.makeLink(url: self.logoImgUrl, completion: { error in
                                                XCTAssertNil(error)
                                                
                                                self.editor.getHTML { html in
                                                    XCTAssertNotNil(html)
                                                    
                                                    if let html = html {
                                                        XCTAssert(html == "<div id=\"\(tagId)\"><a href=\"\(self.logoImgUrl)\" target=\"_blank\">\(value)</a><br></div>")
                                                    }
                                                    
                                                    exp.fulfill()
                                                }
                                            })
                                            
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testRemoveLink() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "logo"
        let value = "123"
        let testHtml = makeTestHTML(id: tagId, value: value)
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.setTextSelection(startElementId: tagId,
                                         startIndex: 0,
                                         endElementId: tagId,
                                         endIndex: value.count,
                                         completion: { error in
                                            XCTAssertNil(error)
                                            
                                            self.editor.makeLink(url: self.logoImgUrl, completion: { error in
                                                XCTAssertNil(error)
                                                
                                                self.editor.removeLink { error in
                                                    XCTAssertNil(error)
                                                    
                                                    self.editor.getHTML { html in
                                                        XCTAssertNotNil(html)
                                                        
                                                        if let html = html {
                                                            XCTAssert(html == "<div id=\"\(tagId)\">\(value)<br></div>")
                                                        }
                                                        
                                                        exp.fulfill()
                                                    }
                                                }
                                            })
                                            
            })
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testClearEditor() {
        let exp = expectation(description: "\(#function)\(#line)")
        
        let tagId = "test"
        let value = "123"
        let testHtml = makeTestHTML(id: tagId, value: value)
        
        editor.insertHTML(testHtml) { error in
            XCTAssertNil(error)
            
            self.editor.clear { error in
                XCTAssertNil(error)
                
                self.editor.getHTML { html in
                    XCTAssertNotNil(html)
                    
                    if let html = html {
                        XCTAssert(html == self.makeTestHTML())
                    }
                    
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    //MARK: - SQTextEditorDelegate
    
    func editorDidLoad(_ editor: SQTextEditorView) {
        editorDidLoadHandler?()
    }
    
    func editor(_ editor: SQTextEditorView, selectedTextAttributeDidChange attribute: SQTextAttribute) {
    }
    
    func editor(_ editor: SQTextEditorView, contentHeightDidChange height: Int) {
        print("contentHeightDidChange = \(height)")
    }
}
