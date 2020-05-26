//
//  ViewController.swift
//  SQRichTextEditor
//
//  Created by conscientiousness on 12/09/2019.
//  Copyright (c) 2019 conscientiousness. All rights reserved.
//

import UIKit
import SQRichTextEditor
import WebKit

class ViewController: UIViewController {
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let _flowLayout = UICollectionViewFlowLayout()
        _flowLayout.scrollDirection = .horizontal
        return _flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let _collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        return _collectionView
    }()
    
    private lazy var editorView: SQTextEditorView = {
        let _editorView = SQTextEditorView(frame: .zero)
        _editorView.delegate = self
        _editorView.translatesAutoresizingMaskIntoConstraints = false
        return _editorView
    }()
    
    private var selectedOption: ToolOptionType?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectioView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.layoutIfNeeded()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(editorView)
        
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: ToolItemCellSettings.height).isActive = true
        
        editorView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10).isActive = true
        editorView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        editorView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        editorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
    }
    
    private func setupCollectioView() {
        collectionView.backgroundColor = .clear
        collectionView.register(ToolItemCell.self, forCellWithReuseIdentifier: ToolItemCellSettings.id)
    }
    
    private lazy var colorPickerNavController: UINavigationController = {
        let colorSelectionController = EFColorSelectionViewController()
        colorSelectionController.delegate = self
        colorSelectionController.color = .black
        colorSelectionController.setMode(mode: .all)
        
        let nav = UINavigationController(rootViewController: colorSelectionController)
        if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
            let doneBtn: UIBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("Done", comment: ""),
                style: .done,
                target: self,
                action: #selector(dismissColorPicker)
            )
            colorSelectionController.navigationItem.rightBarButtonItem = doneBtn
        }
        
        return nav
    }()
    
    private func showColorPicker() {
        self.present(colorPickerNavController, animated: true, completion: nil)
    }
    
    @objc private func dismissColorPicker() {
        colorPickerNavController.dismiss(animated: true, completion: nil)
    }
    
    private func showInputAlert(type: ToolOptionType) {
        var textField: UITextField?
        
        let alertController = UIAlertController(title: type.description, message: nil, preferredStyle: .alert)
        alertController.addTextField { pTextField in
            pTextField.clearButtonMode = .whileEditing
            pTextField.borderStyle = .none
            textField = pTextField
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (pAction) in
            if let inputValue = textField?.text {
                switch type {
                case .makeLink:
                    self.editorView.makeLink(url: inputValue)
                case .insertImage:
                    self.editorView.insertImage(url: inputValue)
                case .setTextSize:
                    self.editorView.setText(size: Int(inputValue) ?? 20)
                case .insertHTML:
                    self.editorView.insertHTML(inputValue)
                default:
                    break
                }
            }
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showAlert(text: String?) {
        let alertController = UIAlertController(title: "", message: text, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ToolOptionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToolItemCellSettings.id, for: indexPath)
        (cell as? ToolItemCell)?.configCell(option: ToolOptionType(rawValue: indexPath.row)!,
                                            attribute: editorView.selectedTextAttribute)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedOption = ToolOptionType(rawValue: indexPath.row)
        
        if let option = selectedOption {
            switch option {
            case .bold:
                editorView.bold()
            case .italic:
                editorView.italic()
            case .strikethrough:
                editorView.strikethrough()
            case .underline:
                editorView.underline()
            case .clear:
                editorView.clear()
            case .removeLink:
                editorView.removeLink()
            case .setTextColor, .setTextBackgroundColor:
                showColorPicker()
            case .insertHTML, .makeLink, .insertImage, .setTextSize:
                showInputAlert(type: option)
            case .getHTML:
                editorView.getHTML { html in
                    self.showAlert(text: html)
                }
            case .focusEditor:
                editorView.focus(true)
            case .blurEditor:
                editorView.focus(false)
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let option = ToolOptionType(rawValue: indexPath.row) else { return .zero }
        
        let width = option.description
            .size(withAttributes: [.font: ToolItemCellSettings.normalfont]).width + 15
        
        return CGSize(width: width, height: ToolItemCellSettings.height)
    }
}

extension ViewController: SQTextEditorDelegate {
    
    func editorDidLoad(_ editor: SQTextEditorView) {
        print("editorDidLoad")
    }
    
    func editor(_ editor: SQTextEditorView, selectedTextAttributeDidChange attribute: SQTextAttribute) {
        collectionView.reloadData()
    }
    
    func editor(_ editor: SQTextEditorView, contentHeightDidChange height: Int) {
        print("contentHeightDidChange = \(height)")
    }
    
    func editorDidFocus(_ editor: SQTextEditorView) {
        print("editorDidFocus")
    }
    
    func editor(_ editor: SQTextEditorView, cursorPositionDidChange position: SQEditorCursorPosition) {
        print(position)
    }
}

extension ViewController: EFColorSelectionViewControllerDelegate {
    
    func colorViewController(_ colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
        if let option = selectedOption {
            switch option {
            case .setTextColor:
                editorView.setText(color: color)
            case .setTextBackgroundColor:
                editorView.setText(backgroundColor: color)
            default:
                break
            }
        }
    }
}
