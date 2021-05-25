//
//  DateInputController.swift
//  My Secret
//
//  Created by Petr on 21.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol DateInputControllerDelegate: class {
    func didTapDone(date: Date)
}

class DateInputController: UIViewController {
    
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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    //    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var monthView: JTACMonthView!
    
    let formatter = DateFormatter()
    
    var selectedDate: Date!
    
    var currentDate: Date!
    
    weak var delegate: DateInputControllerDelegate?
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        currentDate = selectedDate
        formatter.dateFormat = "yyyy MM dd"
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: - Actions
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        delegate?.didTapDone(date: selectedDate)
        dismiss(animated: true)
    }
    
    @IBAction func leftMonthButtonAction(_ sender: Any) {
//        monthView.scrollToSegment(.previous)
        var dateComponent = DateComponents()
        dateComponent.month = -1
        formatter.dateFormat = "yyyy MM dd"
        if let date = Calendar.current.date(byAdding: dateComponent, to: currentDate), date >= formatter.date(from: "2000 01 01")! && date <= Date() {
            currentDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            monthView.scrollToDate(currentDate, animateScroll: false)
        }
        
    }
    
    @IBAction func rightMonthButtonAction(_ sender: Any) {
//        monthView.scrollToSegment(.previous)
        var dateComponent = DateComponents()
        dateComponent.month = 1
        formatter.dateFormat = "yyyy MM dd"
        if let date = Calendar.current.date(byAdding: dateComponent, to: currentDate), date >= formatter.date(from: "2000 01 01")! && date <= Date() {
            currentDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            monthView.scrollToDate(currentDate, animateScroll: false)
        }
        
    }
    
    @IBAction func leftYearButtonAction(_ sender: Any) {
//        monthView.scrollToSegment(.previous)
        var dateComponent = DateComponents()
        dateComponent.year = -1
        
        formatter.dateFormat = "yyyy MM dd"
        if let date = Calendar.current.date(byAdding: dateComponent, to: currentDate), date >= formatter.date(from: "2000 01 01")! && date <= Date() {
            currentDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            monthView.scrollToDate(currentDate, animateScroll: false)
        }
    }
    
    @IBAction func rightYearButtonAction(_ sender: Any) {
//        monthView.scrollToSegment(.previous)
        var dateComponent = DateComponents()
        dateComponent.year = 1
        
        formatter.dateFormat = "yyyy MM dd"
        if let date = Calendar.current.date(byAdding: dateComponent, to: currentDate), date >= formatter.date(from: "2000 01 01")! && date <= Date() {
            currentDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            monthView.scrollToDate(currentDate, animateScroll: false)
        }
    }
    
    // MARK: - Privates
    
    private func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? DayCell  else { return }
        cell.dayLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)

        view?.layoutIfNeeded()
    }

    private func handleCellSelected(cell: DayCell, cellState: CellState) {
        if cellState.isSelected {
            cell.selectedView.layer.cornerRadius =  8
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
        
    private func handleCellTextColor(cell: DayCell, cellState: CellState) {
       if cellState.dateBelongsTo == .thisMonth {
          cell.isHidden = false
       } else {
          cell.isHidden = true
       }
    }
    
    private func setupView() {
        titleLabel.font = UIFont.getFont(font: .sfProTextSemibold, size: 17)
        titleLabel.text = "date".localized()
        cancelButton.titleLabel?.font = UIFont.getFont(font: .sfProTextRegular, size: 17)
        cancelButton.setTitle("cancel".localized(), for: .normal)
        doneButton.titleLabel?.font = UIFont.getFont(font: .sfProTextRegular, size: 17)
        doneButton.setTitle("done".localized(), for: .normal)
        
        yearLabel.font = UIFont.getFont(font: .sfProTextSemibold, size: 17)
        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: selectedDate)
        
        monthLabel.font = UIFont.getFont(font: .sfProTextSemibold, size: 17)
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: selectedDate)
        
        monthView.ibCalendarDataSource = self
        monthView.ibCalendarDelegate = self
        
        monthView.scrollingMode = .stopAtEachCalendarFrame
        
        monthView.scrollToDate(selectedDate, animateScroll: false)
        monthView.selectDates([selectedDate])
    }
}

//MARK: - JTACMonthViewDataSource

extension DateInputController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"

        let startDate = formatter.date(from: "2000 01 01")!
        let endDate = formatter.date(from: "2050 12 31")!
        return ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek: .monday)
    }
}

//MARK: - JTACMonthViewDelegate

extension DateInputController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
       let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCell
       self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
       return cell
    }
        
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
       configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
        selectedDate = date
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        if let newDate = visibleDates.monthDates.first?.date {
            formatter.dateFormat = "MMMM"
            if formatter.locale.identifier == "ru_RU" {
                formatter.monthSymbols = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
            }
            monthLabel.text = formatter.string(from: newDate)
            formatter.dateFormat = "yyyy"
            yearLabel.text = formatter.string(from: newDate)
        }
    }
}


