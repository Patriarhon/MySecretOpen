//
//  DateSearchCell.swift
//  My Secret
//
//  Created by Petr on 29.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol DateSearchCellDelegate: class {
    func dateSwitchChanged(isOn: Bool)
    func datesSelected(beginDate: Date, endDate: Date)
}

class DateSearchCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var dateSelectionView: UIView!
    @IBOutlet weak var monthContainerView: UIView! {
        didSet {
            monthContainerView.backgroundColor = UIColor.clear
            monthContainerView.layer.shadowOpacity = 1
            monthContainerView.layer.shadowRadius = 4
            monthContainerView.layer.shadowColor = Palette.shadow.cgColor
            monthContainerView.layer.shadowOffset = CGSize(width: 3, height: 5)
        }
    }
    @IBOutlet weak var monthClippingView: UIView! {
        didSet {
            monthClippingView.layer.cornerRadius = 8
            monthClippingView.layer.masksToBounds = true
        }
    }

//    @IBOutlet weak var yearLabel: UILabel!
    //    @IBOutlet weak var monthButton: UIButton!
//    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthView: JTACMonthView! {
        didSet {
            monthView.layer.cornerRadius = 8
            monthView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
//    @IBOutlet weak var searchDescriptionLabel: UILabel!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet var dayOfWeekLabels: [UILabel]!
    
    @IBOutlet weak var pickerContainerView: UIView! {
        didSet {
            pickerContainerView.backgroundColor = UIColor.clear
            pickerContainerView.layer.shadowOpacity = 1
            pickerContainerView.layer.shadowRadius = 4
            pickerContainerView.layer.shadowColor = Palette.shadow.cgColor
            pickerContainerView.layer.shadowOffset = CGSize(width: 3, height: 5)
        }
    }
    @IBOutlet weak var pickerClippingView: UIView! {
        didSet {
            pickerClippingView.layer.cornerRadius = 8
            pickerClippingView.layer.masksToBounds = true
        }
    }
//    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerView: DatePickerView!
    
    @IBOutlet weak var imitatorContainerView: UIView! {
        didSet {
            imitatorContainerView.backgroundColor = UIColor.clear
            imitatorContainerView.layer.shadowOpacity = 1
            imitatorContainerView.layer.shadowRadius = 4
            imitatorContainerView.layer.shadowColor = Palette.shadow.cgColor
            imitatorContainerView.layer.shadowOffset = CGSize(width: 3, height: 5)
        }
    }
    @IBOutlet weak var imitatorClippingView: UIView! {
        didSet {
            imitatorClippingView.layer.cornerRadius = 8
            imitatorClippingView.layer.masksToBounds = true
        }
    }
    
    let formatter = DateFormatter()
    
    var selectedDate: Date?
    
    var currentDate = Date()
    
    var isMonthMode = false {
        didSet {
            if isMonthMode {
//                monthContainerView.layer.shadowColor = Palette.orange.cgColor
                monthView.layer.borderWidth = 2
                monthView.layer.borderColor = Palette.orange.cgColor
            } else {
//                monthContainerView.layer.shadowColor = Palette.shadow.cgColor
                monthView.layer.borderWidth = 0
            }
        }
    }
    
    weak var delegate: DateSearchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    //MARK: - Actions
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        dateSelectionView.isHidden = !sender.isOn
        delegate?.dateSwitchChanged(isOn: sender.isOn)
    }
    
    @IBAction func leftMonthButtonAction(_ sender: Any) {
        //        monthView.scrollToSegment(.previous)
        var dateComponent = DateComponents()
        dateComponent.month = -1
        formatter.dateFormat = "yyyy MM dd"
        if let date = Calendar.current.date(byAdding: dateComponent, to: currentDate), date >= formatter.date(from: "2000 01 01")! && date <= Date() {
            currentDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) ?? Date()
            monthView.scrollToDate(currentDate, animateScroll: false)
            
            if isMonthMode {
                selectMonth()
            }
//            monthContainerView.layer.shadowColor = Palette.shadow.cgColor
        }
       
        
    }
    
    @IBAction func rightMonthButtonAction(_ sender: Any) {
        //        monthView.scrollToSegment(.previous)
        var dateComponent = DateComponents()
        dateComponent.month = 1
        formatter.dateFormat = "yyyy MM dd"
        if let date = Calendar.current.date(byAdding: dateComponent, to: currentDate), date >= formatter.date(from: "2000 01 01")! && date <= Date() {
            currentDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) ?? Date()
            monthView.scrollToDate(currentDate, animateScroll: false)
            
            if isMonthMode {
                selectMonth()
            }
//            monthContainerView.layer.shadowColor = Palette.shadow.cgColor
        }
        
        
    }
    
    @IBAction func monthButtonAction(_ sender: Any) {
        monthButton.isSelected = !monthButton.isSelected
        pickerContainerView.isHidden = !monthButton.isSelected
        monthView.deselectAllDates()
        isMonthMode = true
        
        selectMonth()
    }
    
    // MARK: - Privates
    
    private func selectMonth() {
        let calendar = Calendar(identifier: .gregorian)
        let beginComponents = calendar.dateComponents([.year, .month], from: currentDate)
        let beginDate = calendar.date(from: beginComponents)!
        let endComponents = calendar.dateComponents([.year, .month], from: calendar.date(byAdding: .month, value: 1, to: currentDate)!)
        let endDate = calendar.date(from: endComponents)!
        delegate?.datesSelected(beginDate: beginDate, endDate: endDate)
    }
    
    private func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? SearchDayCell  else { return }
        cell.dayLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        
        contentView.layoutIfNeeded()
    }
    
    private func handleCellSelected(cell: SearchDayCell, cellState: CellState) {
        if cellState.isSelected {
            cell.selectedView.layer.cornerRadius =  8
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
    
    private func handleCellTextColor(cell: SearchDayCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
        } else {
            cell.isHidden = true
        }
    }
    
    private func setupView() {
        
        monthView.register(UINib(nibName: "SearchDayCell", bundle: nil), forCellWithReuseIdentifier: "SearchDayCell")
//        monthView.register(SearchDayCell.self, forCellWithReuseIdentifier: "SearchDayCell")
        
        titleLabel.text = "search by date".localized()
//        cancelButton.titleLabel?.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
//        cancelButton.setTitle("cancel".localized(), for: .normal)
//        doneButton.titleLabel?.font = UIFont.getFont(font: .sfProTextRegular, size: 17)
//        doneButton.setTitle("done".localized(), for: .normal)
        
//        yearLabel.font = UIFont.getFont(font: .sfProTextSemibold, size: 17)
//        formatter.dateFormat = "yyyy"
//        yearLabel.text = formatter.string(from: selectedDate)
        
//        monthLabel.font = UIFont.getFont(font: .sfProTextSemibold, size: 17)
        formatter.dateFormat = "yyyy MMMM"
        monthButton.titleLabel?.font = UIFont.getFont(font: .sfProTextSemibold, size: 17)
        monthButton.setTitle(formatter.string(from: selectedDate ?? Date()), for: .normal)
//        monthLabel.text = formatter.string(from: selectedDate ?? Date())
        
        monthView.ibCalendarDataSource = self
        monthView.ibCalendarDelegate = self
        
        monthView.scrollingMode = .stopAtEachCalendarFrame
        
        
        monthView.scrollToDate(selectedDate ?? Date(), animateScroll: false)
        if let selectedDate = selectedDate {
            monthView.selectDates([selectedDate])
        }
        
//        searchDescriptionLabel.text = "searchMonthDescription".localized()
        
//        monthView.allowsMultipleSelection = true
//        monthView.allowsRangedSelection = true
//        monthView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deselectDates)))
        
        for label in dayOfWeekLabels.enumerated() {
            label.element.text = "daysOfWeek\(label.offset)".localized()
        }
        
//        datePicker.maximumDate = Date()
        
        datePickerView.monthDelegate = self
    }
    
    @objc private func deselectDates() {
        monthView.deselectAllDates()
    }
}

//MARK: - JTACMonthViewDataSource

extension DateSearchCell: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2000 01 01")!
        let endDate = Date()
        return ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek: .monday)
    }
}

//MARK: - JTACMonthViewDelegate

extension DateSearchCell: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "SearchDayCell", for: indexPath) as! SearchDayCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
        selectedDate = date
        delegate?.datesSelected(beginDate: date, endDate: Calendar.current.date(byAdding: .day, value: 1, to: date)!)
        
        isMonthMode = false
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        if let newDate = visibleDates.monthDates.first?.date {
            formatter.dateFormat = "MMMM yyyy"
            if formatter.locale.identifier.prefix(2) == "ru" {
                formatter.monthSymbols = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
            }
//            monthLabel.text = formatter.string(from: newDate)
            monthButton.setTitle(formatter.string(from: newDate), for: .normal)
//            monthButton.titleLabel?.text = formatter.string(from: newDate)
//            formatter.dateFormat = "yyyy"
//            yearLabel.text = formatter.string(from: newDate)
        }
    }
}

extension DateSearchCell: DatePickerViewDelegate {
    func didSelect(date: Date) {
        monthView.scrollToDate(date, animateScroll: false)
        currentDate = date
        
        if isMonthMode {
            selectMonth()
        }
    }
}


