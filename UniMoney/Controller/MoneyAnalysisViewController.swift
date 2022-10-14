//
//  MoneyAnalysisViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/06.
//

import UIKit
import Charts
import RealmSwift

class MoneyAnalysisViewController: UIViewController {
    @IBOutlet weak var dateLabelBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var comparingBarChartLabel: UILabel!
    
    @IBOutlet weak var categorySpendingPieChartView: PieChartView!
    @IBOutlet weak var categoryEarningPieChartView: PieChartView!
    @IBOutlet weak var comparingBarChartView: BarChartView!
    
    var currentDateMode: moneyDateMode = moneyDateMode.day
    
    var currentYearForDay: Int?
    var currentMonthForDay: Int?
    var currentDayForDay: Int?
    
    var currentYearForMonth: Int?
    var currentMonthForMonth: Int?
    
    var currentYearForYear: Int?

    let todayDate = Date()
    
    let realm = DataPopulation.shared.realm
    
    var moneyRecords: Results<MoneyRecord>?
    var allSpendingCategories: Results<Category>?
    var allEarningCategories: Results<Category>?
    
    var others = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        allSpendingCategories = realm.objects(Category.self).filter("type == %@", "지출").sorted(byKeyPath: "order", ascending: true)
        allEarningCategories = realm.objects(Category.self).filter("type == %@", "수입").sorted(byKeyPath: "order", ascending: true)
        
        let resultDate = DateManager.shared.getTodayDate()
        
        currentYearForDay = resultDate.0
        currentMonthForDay = resultDate.1
        currentDayForDay = resultDate.2
        
        currentYearForMonth = resultDate.0
        currentMonthForMonth = resultDate.1
        
        currentYearForYear = resultDate.0
        
        let dateRange = DateManager.shared.getDayRange(year: currentYearForDay!, month: currentMonthForDay!, day: currentDayForDay!)
        
        let beginDate = dateRange.0
        let endDate = dateRange.1
        
        moneyRecords = realm.objects(MoneyRecord.self)
            .filter("date BETWEEN {%@, %@}", beginDate, endDate)
        
        configureChartView(type: "지출")
        configureChartView(type: "수입")
        
        configureCompareBarChartView()
        
        configureLabel()
    }
    
    @IBAction func segementedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentDateMode = .day
        case 1:
            currentDateMode = .month
        case 2:
            currentDateMode = .year
        default:
            break
        }
        
        configureChartView(type: "지출")
        configureChartView(type: "수입")
        
        configureCompareBarChartView()
        
        configureLabel()
    }
    
    @IBAction func previousDateButtonTapped(_ sender: Any) {
        switch currentDateMode {
        case .year:
            let result = DateManager.shared.getPreviousYear(year: currentYearForYear!)
            currentYearForYear = result
        case .month:
            let result = DateManager.shared.getPreviousMonth(year: currentYearForMonth!, month: currentMonthForMonth!)
            currentYearForMonth = result.0
            currentMonthForMonth = result.1
        case .day:
            let result = DateManager.shared.getPreviousDay(year: currentYearForDay!, month: currentMonthForDay!, day: currentDayForDay!)
            currentYearForDay = result.0
            currentMonthForDay = result.1
            currentDayForDay = result.2
        }
        
        configureChartView(type: "지출")
        configureChartView(type: "수입")
        
        configureCompareBarChartView()
        
        configureLabel()
    }
    
    @IBAction func nextDateButtonTapped(_ sender: Any) {
        switch currentDateMode {
        case .year:
            let result = DateManager.shared.getNextYear(year: currentYearForYear!)
            currentYearForYear = result
        case .month:
            let result = DateManager.shared.getNextMonth(year: currentYearForMonth!, month: currentMonthForMonth!)
            currentYearForMonth = result.0
            currentMonthForMonth = result.1
        case .day:
            let result = DateManager.shared.getNextDay(year: currentYearForDay!, month: currentMonthForDay!, day: currentDayForDay!)
            currentYearForDay = result.0
            currentMonthForDay = result.1
            currentDayForDay = result.2
        }
        
        configureChartView(type: "지출")
        configureChartView(type: "수입")
        
        configureCompareBarChartView()
        
        configureLabel()
    }
    
    private func configureChartView(type: String) {
        switch currentDateMode {
        case .year:
            getDataForYear(year: currentYearForYear!)
        case .month:
            getDataForMonth(year: currentYearForMonth!, month: currentMonthForMonth!)
        case .day:
            getDataForDay(year: currentYearForDay!, month: currentMonthForDay!, day: currentDayForDay!)
        }
        
        var categoryArray: [Category] = []
        
        if type == "지출" {
            moneyRecords = moneyRecords!
                .filter("type == %@", "지출")
            categoryArray = Array(allSpendingCategories!)
        } else if type == "수입" {
            moneyRecords = moneyRecords!
                .filter("type == %@", "수입")
            categoryArray = Array(allEarningCategories!)
        }
        
        if moneyRecords!.count > 0 {
            let total: Int = moneyRecords!
                .sum(ofProperty: "value")
            var resultData: [Category: Double] = [:]
            
            categoryArray.forEach { [weak self] category in
                guard let self = self else { return }
                let spendingWithThisCategory: Int = self.moneyRecords!
                    .filter("category == %@", category)
                    .sum(ofProperty: "value")
                let percentage = Double(spendingWithThisCategory) / Double(total)
                if percentage < 0.01 {
                    self.others += percentage
                    return
                }
                resultData[category] = percentage
            }
            
            var myEntries = resultData.map { dictValue -> PieChartDataEntry in
                return PieChartDataEntry(value: dictValue.value * 100, label: dictValue.key.name, data: dictValue.key)
            }
            if others > 0.0 {
                myEntries.append(PieChartDataEntry(value: others * 100, label: "기타"))
            }
            
            let dataSet = PieChartDataSet(entries: myEntries, label: "")
            dataSet.sliceSpace = 1
            dataSet.entryLabelColor = .black
            dataSet.valueTextColor = .black
            dataSet.valueFormatter = CustomVF()
            dataSet.xValuePosition = .outsideSlice
            dataSet.valueLinePart1OffsetPercentage = 0.8
            dataSet.valueLinePart1Length = 0.2
            dataSet.valueLinePart2Length = 0.3
            dataSet.valueFont = UIFont.systemFont(ofSize: 11, weight: .regular)
            dataSet.entryLabelFont = UIFont.systemFont(ofSize: 9, weight: .light)
            
            dataSet.colors = ChartColorTemplates.vordiplom() + ChartColorTemplates.joyful() + ChartColorTemplates.liberty() + ChartColorTemplates.pastel() + ChartColorTemplates.material()
            if type == "지출" {
                categorySpendingPieChartView.data = PieChartData(dataSet: dataSet)
                categorySpendingPieChartView.spin(duration: 0.3, fromAngle: categorySpendingPieChartView.rotationAngle, toAngle: categorySpendingPieChartView.rotationAngle + 80)
            } else if type == "수입" {
                categoryEarningPieChartView.data = PieChartData(dataSet: dataSet)
                categoryEarningPieChartView.spin(duration: 0.3, fromAngle: categoryEarningPieChartView.rotationAngle, toAngle: categoryEarningPieChartView.rotationAngle + 80)
            }
        } else {
            if type == "지출" {
                categorySpendingPieChartView.noDataText = "표시할 데이터가 없습니다."
                categorySpendingPieChartView.clear()
            } else if type == "수입" {
                categoryEarningPieChartView.noDataText = "표시할 데이터가 없습니다."
                categoryEarningPieChartView.clear()
            }
        }
        
        categorySpendingPieChartView.isUserInteractionEnabled = false
        categoryEarningPieChartView.isUserInteractionEnabled = false
    }
    
    private func configureCompareBarChartView() {
        var firstValue = 0
        var secondValue = 0
        
        var labelText = "비교 바 그래프"
        
        switch currentDateMode {
        case .year:
            getDataForYear(year: currentYearForYear!)
            
            secondValue = moneyRecords!
                .filter("type == %@", "지출")
                .sum(ofProperty: "value")
            
            let lastYearComponent = DateManager.shared.getPreviousYear(year: currentYearForYear!)
            
            getDataForYear(year: lastYearComponent)
            
            firstValue = moneyRecords!
                .filter("type == %@", "지출")
                .sum(ofProperty: "value")
            
            labelText = "\(lastYearComponent)년 | \(currentYearForYear!)년"
        case .month:
            getDataForMonth(year: currentYearForMonth!, month: currentMonthForMonth!)
            
            secondValue = moneyRecords!
                .filter("type == %@", "지출")
                .sum(ofProperty: "value")
            
            let lastMonthComponent = DateManager.shared.getPreviousMonth(year: currentYearForMonth!, month: currentMonthForMonth!)
            
            getDataForMonth(year: lastMonthComponent.0, month: lastMonthComponent.1)
            
            firstValue = moneyRecords!
                .filter("type == %@", "지출")
                .sum(ofProperty: "value")
            
            labelText = "\(lastMonthComponent.0)년 \(lastMonthComponent.1)월 | \(currentYearForMonth!)년 \(currentMonthForMonth!)월"
        case .day:
            getDataForDay(year: currentYearForDay!, month: currentMonthForDay!, day: currentDayForDay!)
            
            secondValue = moneyRecords!
                .filter("type == %@", "지출")
                .sum(ofProperty: "value")
            
            let yesterdayComponent = DateManager.shared.getPreviousDay(year: currentYearForDay!, month: currentMonthForDay!, day: currentDayForDay!)
            
            getDataForDay(year: yesterdayComponent.0, month: yesterdayComponent.1, day: yesterdayComponent.2)
            
            firstValue = moneyRecords!
                .filter("type == %@", "지출")
                .sum(ofProperty: "value")
            
            labelText = "\(yesterdayComponent.1)월 \(yesterdayComponent.2)일 | \(currentMonthForDay!)월 \(currentDayForDay!)일"
        }
        
        if firstValue == 0 && secondValue == 0 {
            comparingBarChartView.noDataText = "비교할 데이터가 없습니다."
            comparingBarChartView.clear()
        } else {
            comparingBarChartView.animate(yAxisDuration: 2.0)
            comparingBarChartView.pinchZoomEnabled = false
            comparingBarChartView.drawBarShadowEnabled = false
            comparingBarChartView.drawBordersEnabled = false
            comparingBarChartView.drawGridBackgroundEnabled = false
            comparingBarChartView.xAxis.drawGridLinesEnabled = false
            comparingBarChartView.xAxis.drawLabelsEnabled = false
            comparingBarChartView.leftAxis.drawLabelsEnabled = false
            comparingBarChartView.rightAxis.drawLabelsEnabled = false
            
            var dataEntries: [BarChartDataEntry] = []
            
            dataEntries.append(BarChartDataEntry(x: Double(0), y: Double(firstValue)))
            dataEntries.append(BarChartDataEntry(x: Double(1), y: Double(secondValue)))
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: labelText)
            chartDataSet.colors = [.systemBrown, .systemPurple]
            chartDataSet.valueFormatter = CustomVF2()
            chartDataSet.valueFont = UIFont.systemFont(ofSize: 11, weight: .regular)
            
            let chartData = BarChartData(dataSet: chartDataSet)
            comparingBarChartView.data = chartData
        }
        
        comparingBarChartView.isUserInteractionEnabled = false
    }
    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        return colors
    }
    
    private func getDataForDay(year: Int, month: Int, day: Int) {
        let dateRange = DateManager.shared.getDayRange(year: year, month: month, day: day)
        
        let beginDate = dateRange.0
        let endDate = dateRange.1
        
        moneyRecords = realm.objects(MoneyRecord.self)
            .filter("date BETWEEN {%@, %@}", beginDate, endDate)
    }
    
    private func getDataForMonth(year: Int, month: Int) {
        let dateRange = DateManager.shared.getMonthRange(year: year, month: month)
        
        let beginDate = dateRange.0
        let endDate = dateRange.1
        
        moneyRecords = realm.objects(MoneyRecord.self)
            .filter("date BETWEEN {%@, %@}", beginDate, endDate)
    }
    
    private func getDataForYear(year: Int) {
        let dateRange = DateManager.shared.getYearRange(year: year)
        
        let beginDate = dateRange.0
        let endDate = dateRange.1
        
        moneyRecords = realm.objects(MoneyRecord.self)
            .filter("date BETWEEN {%@, %@}", beginDate, endDate)
    }
    
    private func configureLabel() {
        switch currentDateMode {
        case .year:
            let date = DateManager.shared.getDate(year: currentYearForYear!)
            dateLabelBarButtonItem.title = date.yearString
            comparingBarChartLabel.text = "전년 지출 비교"
        case .month:
            let todayComponents = DateManager.shared.getTodayDate()
            let date = DateManager.shared.getDate(year: currentYearForMonth!, month: currentMonthForMonth!)
            
            if todayComponents.0 == currentYearForMonth {
                dateLabelBarButtonItem.title = date.monthString
            } else {
                dateLabelBarButtonItem.title = date.yearMonthString
            }
            
            comparingBarChartLabel.text = "전월 지출 비교"
        case .day:
            let todayComponents = DateManager.shared.getTodayDate()
            
            if todayComponents.0 == currentYearForDay, todayComponents.1 == currentMonthForDay, todayComponents.2 == currentDayForDay {
                dateLabelBarButtonItem.title = "오늘"
            } else if todayComponents.0 == currentYearForDay {
                let date = DateManager.shared.getDate(year: currentYearForDay!, month: currentMonthForDay!, day: currentDayForDay!)
                dateLabelBarButtonItem.title = date.dateString
            } else {
                let date = DateManager.shared.getDate(year: currentYearForDay!, month: currentMonthForDay!, day: currentDayForDay!)
                dateLabelBarButtonItem.title = date.yearMonthDayString
            }
            
            comparingBarChartLabel.text = "전일 지출 비교"
        }
    }
}

class CustomVF : ValueFormatter {
var maxValue : Double = 1
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "\(round(value))%"
    }
}

class CustomVF2 : ValueFormatter {
var maxValue : Double = 1
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let value = NSNumber(value: Int(value))
        return "\(value.numberToText!)원"
    }
}
