//
//  TextInputController.swift
//  My Secret
//
//  Created by Petr on 14.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import SwiftEntryKit

enum StringType: String {
    case heading = "heading"
    case place = "place"
    case thoughts = "thoughts"
    
    var limit: Int {
        switch self {
        case .heading:
            return 30
        case .place:
            return 20
        case .thoughts:
            return 1000
        }
    }
    
    var defaultColor: UIColor {
        switch self {
        case .heading:
            return Palette.darkBlue
        case .place:
            return Palette.lightGray
        case .thoughts:
            return Palette.gray
        }
    }
    
    var storyFonts: [UIFont] {
        switch self {
        case .heading:
            return [
                UIFont.getFont(font: .sfProTextMedium, size: 14),
                UIFont.getFont(font: .monAmourOneMedium, size: 14),
                UIFont.getFont(font: .italyB, size: 14),
                UIFont.getFont(font: .tickerTape, size: 14)
            ]
        case .place, .thoughts:
            return [
                UIFont.getFont(font: .sfProTextRegular, size: 14),
                UIFont.getFont(font: .monAmourOneMedium, size: 14),
                UIFont.getFont(font: .italyB, size: 14),
                UIFont.getFont(font: .tickerTape, size: 14)
            ]
        }
    }
}

protocol TextInputControllerDelegate: class {
    func didTapDone(text: String, mode: StringType, color: UIColor, fontNumber: Int)
}

class TextInputController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    var mode: StringType!
    var text = ""
    var color: UIColor!
    var fontNumber = 0
    
    weak var delegate: TextInputControllerDelegate?
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        bodyTextView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        dismissKeyboard()
    }
    
    //MARK: - Actions
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        delegate?.didTapDone(text: bodyTextView.text, mode: mode, color: color, fontNumber: fontNumber)
        dismiss(animated: true)
    }
    
    @IBAction func colorButtonAction(_ sender: Any) {
        dismissKeyboard()
        showColorPicker()
    }
    
    @IBAction func fontButtonAction(_ sender: Any) {
        dismissKeyboard()
        showFontPicker()
    }
    
    //MARK: - Notifications
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue )?.cgRectValue else {return}
        
        var offset: CGFloat = 0
        
        let bottomOfLimitLabel = limitLabel.convert(limitLabel.bounds, to: self.view).maxY
        let topOfKeyboard = self.view.frame.height - keyboardSize.height
        
        if bottomOfLimitLabel + 16 > topOfKeyboard {
            offset = bottomOfLimitLabel - topOfKeyboard + 16
        }
        self.stackViewBottomConstraint.constant += offset
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.stackViewBottomConstraint.constant = 16
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Private
    
    private func setupPopupAttributes() -> EKAttributes {
        var attributes = EKAttributes.bottomFloat
        attributes.displayDuration = .infinity
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.14, radius: 11, offset: CGSize(width: 3, height: 5)))
//        attributes.screenInteraction = .init(defaultAction: .dismissEntry, customTapActions: [
//            resetColor,
//            resetFont
//        ])
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.positionConstraints.verticalOffset = 8
        attributes.entryBackground = .color(color: .standardBackground)
        attributes.roundCorners = .all(radius: 8)
        
        return attributes
    }
    
    private func showColorPicker() {
        let colorPickerView = ColorPickerView()
        colorPickerView.set(color: color)
        colorPickerView.delegate = self
        SwiftEntryKit.display(entry: colorPickerView, using: setupPopupAttributes())
    }
    
    private func showFontPicker() {
        let fontPickerView = FontPickerView()
        fontPickerView.set(fontNumber: fontNumber, mode: mode)
        fontPickerView.delegate = self
        SwiftEntryKit.display(entry: fontPickerView, using: setupPopupAttributes())
    }
    
    private func resetColor() {
        bodyTextView.textColor = color
    }
    
    private func resetFont() {
        bodyTextView.font = mode.storyFonts[fontNumber]
    }
    
    private func setupView() {
        titleLabel.font = UIFont.getFont(font: .sfProTextSemibold, size: 17)
        titleLabel.text = mode.rawValue.localized()
        cancelButton.titleLabel?.font = UIFont.getFont(font: .sfProTextRegular, size: 17)
        cancelButton.setTitle("cancel".localized(), for: .normal)
        doneButton.titleLabel?.font = UIFont.getFont(font: .sfProTextRegular, size: 17)
        doneButton.setTitle("done".localized(), for: .normal)
        bodyTextView.delegate = self
        bodyTextView.font = mode.storyFonts[fontNumber].withSize(17)
        bodyTextView.text = text
        bodyTextView.textColor = color
        limitLabel.font = UIFont.getFont(font: .sfProTextRegular, size: 12)
        limitLabel.text = "\(text.count)/\(mode.limit)"
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension TextInputController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
//        if text == "\n" {
//            textView.resignFirstResponder()
//            return false
//        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        limitLabel.text = numberOfChars <= mode.limit ? "\(numberOfChars)/\(mode.limit)" : "\(mode.limit)/\(mode.limit)"
        return numberOfChars <= mode.limit
    }
}

extension TextInputController: ColorPickerViewDelegate {
    func saveColor() {
        color = bodyTextView.textColor
        SwiftEntryKit.dismiss()
    }
    
    func cancelColor() {
        bodyTextView.textColor = color ?? Palette.black
        SwiftEntryKit.dismiss()
    }
    
    func colorChanged(color: UIColor) {
        bodyTextView.textColor = color
    }
}

extension TextInputController: FontPickerViewDelegate {
    func fontChanged(number: Int) {
        bodyTextView.font = mode.storyFonts[number].withSize(17)
    }
    
    func saveFont(number: Int) {
        fontNumber = number
        SwiftEntryKit.dismiss()
    }
    
    func cancelFont() {
        bodyTextView.font = mode.storyFonts[fontNumber]
        SwiftEntryKit.dismiss()
    }
    
    
}
