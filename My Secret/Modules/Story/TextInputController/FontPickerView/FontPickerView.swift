//
//  FontPickerView.swift
//  My Secret
//
//  Created by Petr on 14.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

protocol FontPickerViewDelegate: class {
    func fontChanged(number: Int)
    func saveFont(number: Int)
    func cancelFont()
}

class FontPickerView: NibView {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var cancelLabel: UILabel!
    
    weak var delegate: FontPickerViewDelegate?
    
    var datasource = [UIFont]()
    var startFontNumber: Int!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        saveLabel.font = UIFont.getFont(font: .sfCompactTextRegular, size: 14)
        saveLabel.text = "save".localized()
        
        cancelLabel.font = UIFont.getFont(font: .sfCompactTextRegular, size: 14)
        cancelLabel.text = "cancel".localized()
        
        pickerView.selectRow(startFontNumber, inComponent: 0, animated: false)
        
//        pickerView.selectRow(2, inComponent: 0, animated: true)
        
    }
    
    func set(fontNumber: Int, mode: StringType) {
        datasource = mode.storyFonts
        startFontNumber = fontNumber
        pickerView.reloadAllComponents()
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        delegate?.saveFont(number: pickerView.selectedRow(inComponent: 0))
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        delegate?.cancelFont()
    }
}

extension FontPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datasource.count
    }
    
    
}

extension FontPickerView: UIPickerViewDelegate {
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        let font = datasource[row]
//        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.backgroundColor: UIColor.yellow] as [NSAttributedString.Key: Any]
//        let attributedTitle = NSAttributedString(string: font.familyName, attributes: attributes)
//        return attributedTitle
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.fontChanged(number: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        guard let label = view as? UILabel else {
//          preconditionFailure ("Expected a Label")
//        }
        
        let label = UILabel()
        label.textAlignment = .center

//        let fonSize: CGFloat = row == 1 ? 22 : 17
        let font = datasource[row].withSize(17)
        let attributes = [NSAttributedString.Key.font: font] as [NSAttributedString.Key: Any]
        let attributedTitle = NSAttributedString(string: font.familyName, attributes: attributes)
        
        label.attributedText = attributedTitle
        return label
    }
}
