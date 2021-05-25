//
//  ColorPickerView.swift
//  My Secret
//
//  Created by Petr on 14.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import Colorful

protocol ColorPickerViewDelegate: class {
    func colorChanged(color: UIColor)
    func saveColor()
    func cancelColor()
}

class ColorPickerView: NibView {
    
    @IBOutlet weak var colorPicker: ColorPicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var cancelLabel: UILabel!
    
    weak var delegate: ColorPickerViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        saveLabel.font = UIFont.getFont(font: .sfCompactTextRegular, size: 14)
        saveLabel.text = "save".localized()
        
        cancelLabel.font = UIFont.getFont(font: .sfCompactTextRegular, size: 14)
        cancelLabel.text = "cancel".localized()
        
        colorPicker.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
//        colorPicker.set(color: .red, colorSpace: .extendedSRGB)
    }
    
    func set(color: UIColor?) {
        colorPicker.set(color: color ?? Palette.black, colorSpace: .sRGB)
    }
    
    @objc private func colorChanged() {
        delegate?.colorChanged(color: colorPicker.color)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        delegate?.saveColor()
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        delegate?.cancelColor()
    }
}
