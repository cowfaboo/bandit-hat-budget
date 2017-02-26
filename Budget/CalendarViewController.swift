//
//  CalendarViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-02-19.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

protocol CalendarDelegate: class {
  func shouldDismissCalendar(withChosenDate date: Date?)
}

struct SimpleDate {
  var weekday: Int
  var day: Int
  var month: Int
  var year: Int
}

class CalendarViewController: UIViewController {
  
  weak var calendarDelegate: CalendarDelegate?
  
  var themeColor = UIColor.text
  
  @IBOutlet weak var calendarCollectionView: UICollectionView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var leftButton: UIButton!
  @IBOutlet weak var rightButton: UIButton!
  @IBOutlet weak var topView: UIView!
  
  @IBOutlet var weekdayLabels: Array<UILabel>!
  
  var currentDate = Date()
  var selectedDate: Date? {
    didSet {
      if let selectedDate = selectedDate {
        (_, startOfDisplayedMonth) = selectedDate.startAndEndOfMonth()
      } else {
        (_, startOfDisplayedMonth) = Date().startAndEndOfMonth()
      }
    }
  }
  var (_, startOfDisplayedMonth) = Date().startAndEndOfMonth()
  var displayedDates: [SimpleDate] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    calendarCollectionView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellWithReuseIdentifier: "CalendarCell")
    
    initializeDisplayedDates()
    
    titleLabel.text = startOfDisplayedMonth.monthYearString()
    titleLabel.textColor = UIColor.white
    leftButton.tintColor = UIColor.white
    rightButton.tintColor = UIColor.white
    for label in weekdayLabels { label.textColor = UIColor.white }
    topView.backgroundColor = themeColor
    
    self.view.layer.allowsEdgeAntialiasing = true
    self.topView.layer.allowsEdgeAntialiasing = true
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func initializeDisplayedDates() {
    
    displayedDates = []
    
    let startAndEndOfMonth = startOfDisplayedMonth.startAndEndOfMonth()
    
    let startDateComponents = Calendar.current.dateComponents([.weekday, .day, .month, .year], from: startAndEndOfMonth.startDate)
    let endDateComponents = Calendar.current.dateComponents([.weekday, .day, .month, .year], from: startAndEndOfMonth.endDate)
    
    if startDateComponents.weekday! != 1 {
      
      let startOfPreviousMonth = startOfDisplayedMonth.startOfPreviousMonth()
      let (_, endOfPreviousMonth) = startOfPreviousMonth.startAndEndOfMonth()
      let previousEndDateComponents = Calendar.current.dateComponents([.weekday, .day, .month, .year], from: endOfPreviousMonth)
      
      let startingWeekday = startDateComponents.weekday! - 1
      
      for weekday in 1...startingWeekday {
        let simpleDate = SimpleDate(weekday: weekday, day: previousEndDateComponents.day! - (startingWeekday - weekday), month: previousEndDateComponents.month!, year: previousEndDateComponents.year!)
        displayedDates.append(simpleDate)
      }
    }
    
    
    var weekday = startDateComponents.weekday!
    for day in startDateComponents.day!...endDateComponents.day! {
      let simpleDate = SimpleDate(weekday: weekday, day: day, month: startDateComponents.month!, year: startDateComponents.year!)
      displayedDates.append(simpleDate)
      if weekday == 7 {
        weekday = 1
      } else {
        weekday += 1
      }
    }
    
    if displayedDates.count == 42 {
      return
    }
    
    let startOfNextMonth = startOfDisplayedMonth.startOfNextMonth()
    let nextStartDateComponents = Calendar.current.dateComponents([.weekday, .day, .month, .year], from: startOfNextMonth)
    
    weekday = nextStartDateComponents.weekday!
    for day in 1...(42 - displayedDates.count) {
      let simpleDate = SimpleDate(weekday: weekday, day: day, month: nextStartDateComponents.month!, year: nextStartDateComponents.year!)
      displayedDates.append(simpleDate)
      if weekday == 7 {
        weekday = 1
      } else {
        weekday += 1
      }
    }
  }
  
  // MARK: - Action Methods
  @IBAction func leftButtonTapped() {
    startOfDisplayedMonth = startOfDisplayedMonth.startOfPreviousMonth()
    titleLabel.text = startOfDisplayedMonth.monthYearString()
    initializeDisplayedDates()
    calendarCollectionView.reloadData()
  }
  
  @IBAction func rightButtonTapped() {
    startOfDisplayedMonth = startOfDisplayedMonth.startOfNextMonth()
    titleLabel.text = startOfDisplayedMonth.monthYearString()
    initializeDisplayedDates()
    calendarCollectionView.reloadData()
  }
}

// MARK: - Collection View Flow Layout Delegate Methods
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.size.width / 7, height: collectionView.frame.size.height / 6)
  }
}

// MARK: - Collection View Data Source Methods
extension CalendarViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return displayedDates.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
    cell.themeColor = themeColor
    
    
    let simpleDate = displayedDates[indexPath.item]
    var shouldDimDate = false
    var shouldHighlightDate = false
    var shouldSelectDate = false
    
    let displayedMonth = Calendar.current.dateComponents([.month], from: startOfDisplayedMonth).month!
    if simpleDate.month != displayedMonth {
      shouldDimDate = true
    }
    
    let currentDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: currentDate)
    let currentDay = currentDateComponents.day
    let currentMonth = currentDateComponents.month
    let currentYear = currentDateComponents.year
    if simpleDate.day == currentDay && simpleDate.month == currentMonth && simpleDate.year == currentYear {
      shouldHighlightDate = true
    }
    
    if let selectedDate = selectedDate {
      let selectedDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: selectedDate)
      let selectedDay = selectedDateComponents.day
      let selectedMonth = selectedDateComponents.month
      let selectedYear = selectedDateComponents.year
      if simpleDate.day == selectedDay && simpleDate.month == selectedMonth && simpleDate.year == selectedYear {
        shouldSelectDate = true
      }
    }
    
    cell.initialize(withDay: simpleDate.day, shouldDimDate: shouldDimDate, shouldHighlightDate: shouldHighlightDate, shouldSelectDate: shouldSelectDate)
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let selectedSimpleDate = displayedDates[indexPath.item]
    
    let selectedDateComponents = DateComponents(year: selectedSimpleDate.year, month: selectedSimpleDate.month, day: selectedSimpleDate.day)
    
    selectedDate = Calendar.current.date(from: selectedDateComponents)
    calendarCollectionView.reloadData()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.calendarDelegate?.shouldDismissCalendar(withChosenDate: self.selectedDate)
    }
  }
}
