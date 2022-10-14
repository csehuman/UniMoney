//
//  MoneyListViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/06.
//

import UIKit
import UserNotifications
import RealmSwift

enum moneyDateMode {
    case year
    case month
    case day
}

class MoneyListViewController: UIViewController {
    @IBOutlet weak var dateLabelBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var spendingView: UIView!
    @IBOutlet weak var earningView: UIView!
    
    @IBOutlet weak var spentMoneyLabel: UILabel!
    @IBOutlet weak var earnedMoneyLabel: UILabel!
    
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var addRecordButton: UIButton!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyTextLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var totalRecordLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterCancelButton: UIButton!
    
    
    var currentDateMode: moneyDateMode = moneyDateMode.day
    
    var currentYearForDay: Int?
    var currentMonthForDay: Int?
    var currentDayForDay: Int?
    
    var currentYearForMonth: Int?
    var currentMonthForMonth: Int?
    
    var currentYearForYear: Int?

    let todayDate = Date()
    
    var token: NSObjectProtocol?
    
    var moneyRecords: Results<MoneyRecord>?
    
    var allSpendingCategories: Results<Category>?
    var allEarningCategories: Results<Category>?
    var allPaymentMethods: Results<PaymentMethod>?
    
    var selectedSpendingCategories = [Category]()
    var selectedEarningCategories = [Category]()
    var selectedPaymentMethods = [PaymentMethod]()
    
    var inFilterState: Bool = false
    
    let realm = DataPopulation.shared.realm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spendingView.layer.cornerRadius = 5
        spendingView.backgroundColor = .white
        spendingView.layer.borderColor = UIColor.systemRed.cgColor
        spendingView.layer.borderWidth = 0.5
        
        spentMoneyLabel.textColor = .systemRed
        
        earningView.layer.cornerRadius = 5
        earningView.backgroundColor = .white
        earningView.layer.borderColor = UIColor.systemPurple.cgColor
        earningView.layer.borderWidth = 0.5
        
        earnedMoneyLabel.textColor = .systemPurple
        
        
        addRecordButton.layer.cornerRadius = 10
        
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "추가하기"
            configuration.image = UIImage(systemName: "pencil")
            configuration.imagePadding = 10
            configuration.baseBackgroundColor = .systemPurple
            
            addRecordButton.configuration = configuration
        } else {
            // Fallback on earlier versions
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let nibName = UINib(nibName: "MoneyTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "MoneyTableViewCell")
        
        allSpendingCategories = realm.objects(Category.self).filter("type == %@", "지출").sorted(byKeyPath: "order", ascending: true)
        allEarningCategories = realm.objects(Category.self).filter("type == %@", "수입").sorted(byKeyPath: "order", ascending: true)
        allPaymentMethods = realm.objects(PaymentMethod.self).sorted(byKeyPath: "order", ascending: true)
        
        selectedSpendingCategories = Array(allSpendingCategories!)
        selectedEarningCategories = Array(allEarningCategories!)
        selectedPaymentMethods = Array(allPaymentMethods!)
        
        let now = Date()
        let calendar = Calendar.current
        
        guard let beginDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else { return }
        guard let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) else { return }
        
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        currentYearForDay = components.year
        currentMonthForDay = components.month
        currentDayForDay = components.day
        
        currentYearForMonth = components.year
        currentMonthForMonth = components.month
        
        currentYearForYear = components.year
        
        moneyRecords = realm.objects(MoneyRecord.self)
            .filter("date BETWEEN {%@, %@}", beginDate, endDate)
            .sorted(byKeyPath: "date", ascending: false)
        
        dateLabelBarButtonItem.title = "오늘"
        
        configureLabels()
        
        token = NotificationCenter.default.addObserver(forName: NSNotification.Name("moneyRecordSaved"), object: nil, queue: OperationQueue.main) { [weak self] noti in
            self?.configureLabels()
            self?.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "filterToMain"), object: nil, queue: OperationQueue.main) { [weak self] noti in
            guard let dict = noti.object as? [String: Any] else { return }
            guard let spentChecked = dict["spentChecked"] as? Bool else { return }
            guard let earnedChecked = dict["earnedChecked"] as? Bool else { return }
            guard let spendingCategories = dict["selectedSpendingCategories"] as? [Category] else { return }
            guard let earningCategories = dict["selectedEarningCategories"] as? [Category] else { return }
            guard let paymentMethods = dict["selectedPaymentMethods"] as? [PaymentMethod] else { return }
            
            self?.selectedSpendingCategories = spendingCategories
            self?.selectedEarningCategories = earningCategories
            self?.selectedPaymentMethods = paymentMethods
            
            self?.inFilterState = true
            
            if !spentChecked {
                self?.selectedSpendingCategories = []
                self?.filterButton.setTitle("수입 | 결제수단", for: .normal)
            } else if !earnedChecked {
                self?.selectedEarningCategories = []
                self?.filterButton.setTitle("지출 | 결제수단", for: .normal)
            } else {
                self?.filterButton.setTitle("지출 | 수입 | 결제수단", for: .normal)
            }
            
            self?.filterCancelButton.isHidden = false
            
            if self?.currentDateMode == .day {
                self?.updateTableViewForDay()
            } else if self?.currentDateMode == .month {
                self?.updateTableViewForMonth()
            } else if self?.currentDateMode == .year {
                self?.updateTableViewForYear()
            }
        }
    }
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let filterViewVC = segue.destination as? FilterViewController else { return }
        
        filterViewVC.allPaymentMethods = allPaymentMethods
        filterViewVC.allSpendingCategories = allSpendingCategories
        filterViewVC.allEarningCategories = allEarningCategories
        
        filterViewVC.selectedPaymentMethods = selectedPaymentMethods
        filterViewVC.selectedSpendingCategories = selectedSpendingCategories
        filterViewVC.selectedEarningCategories = selectedEarningCategories
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentDateMode = .day
            updateTableViewForDay()
        case 1:
            currentDateMode = .month
            updateTableViewForMonth()
        case 2:
            currentDateMode = .year
            updateTableViewForYear()
        default:
            break
        }
    }
    
    @IBAction func filterCancelButtonTapped(_ sender: UIButton) {
        filterCancelButton.isHidden = true
        filterButton.setTitle("필터", for: .normal)
        
        inFilterState = false
        
        selectedSpendingCategories = Array(allSpendingCategories!)
        selectedEarningCategories = Array(allEarningCategories!)
        selectedPaymentMethods = Array(allPaymentMethods!)
        
        if currentDateMode == .day {
            updateTableViewForDay()
        } else if currentDateMode == .month {
            updateTableViewForMonth()
        } else if currentDateMode == .year {
            updateTableViewForYear()
        }
    }
    
    
    @IBAction func previousDateButtonTapped(_ sender: UIBarButtonItem) {
        if inFilterState {
            let alert = UIAlertController(title: "필터 해제 후 기간을 변경해주세요.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        } else {
            switch currentDateMode {
            case .year:
                currentYearForYear = currentYearForYear! - 1
                updateTableViewForYear()
            case .month:
                if currentMonthForMonth == 1 {
                    currentMonthForMonth = 12
                    currentYearForMonth = currentYearForMonth! - 1
                } else {
                    currentMonthForMonth = currentMonthForMonth! - 1
                }
                updateTableViewForMonth()
            case .day:
                if currentDayForDay == 1 {
                    if currentMonthForDay == 1 {
                        currentMonthForDay = 12
                        currentYearForDay = currentYearForDay! - 1
                    } else {
                        currentMonthForDay = currentMonthForDay! - 1
                    }
                    currentDayForDay = getLastDayOfMonthComponents(forMonth: currentMonthForDay!).day!
                } else {
                    currentDayForDay = currentDayForDay! - 1
                }
                updateTableViewForDay()
            }
        }
    }
    
    @IBAction func nextDateButtonTapped(_ sender: UIBarButtonItem) {
        if inFilterState {
            let alert = UIAlertController(title: "필터 해제 후 기간을 변경해주세요.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        } else {
            switch currentDateMode {
            case .year:
                currentYearForYear = currentYearForYear! + 1
                updateTableViewForYear()
            case .month:
                if currentMonthForMonth == 12 {
                    currentMonthForMonth = 1
                    currentYearForMonth = currentYearForMonth! + 1
                } else {
                    currentMonthForMonth = currentMonthForMonth! + 1
                }
                updateTableViewForMonth()
            case .day:
                if currentDayForDay == getLastDayOfMonthComponents(forMonth: currentMonthForDay!).day! {
                    if currentMonthForDay == 12 {
                        currentMonthForDay = 1
                        currentYearForDay = currentYearForDay! + 1
                    } else {
                        currentMonthForDay = currentMonthForDay! + 1
                    }
                    currentDayForDay = 1
                } else {
                    currentDayForDay = currentDayForDay! + 1
                }
                updateTableViewForDay()
            }
        }
    }
    
    private func getLastDayOfMonthComponents(forMonth month: Int) -> DateComponents {
        let dateComponents = ["year": 2001, "month": month, "day": 1, "hour": 0, "minute": 0, "second": 0]
        let date = makeDate(from: dateComponents)
        
        let components = DateComponents(month: 1, second: -1)
        let endMonth = Calendar(identifier: .gregorian).date(byAdding: components, to: date)!
        let calendarDate = Calendar.current.dateComponents([.day], from: endMonth)
        
        return calendarDate
    }
    
    private func makeDate(from components: [String: Int]) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = components["year"]
        dateComponents.month = components["month"]
        dateComponents.day = components["day"]
        dateComponents.hour = components["hour"]
        dateComponents.minute = components["minute"]
        dateComponents.second = components["second"]
        
        let resultDate = Calendar(identifier: .gregorian).date(from: dateComponents)
        
        return resultDate!
    }
    
    private func updateTableViewForDay() {
        guard let currentYearForDay = currentYearForDay, let currentMonthForDay = currentMonthForDay, let currentDayForDay = currentDayForDay else {
            return
        }
        
        let beginDateComponents = ["year": currentYearForDay, "month": currentMonthForDay, "day": currentDayForDay, "hour": 0, "minute": 0, "second": 0]
        let endDateComponents = ["year": currentYearForDay, "month": currentMonthForDay, "day": currentDayForDay, "hour": 23, "minute": 59, "second": 59]
        
        let beginDate = makeDate(from: beginDateComponents)
        let endDate = makeDate(from: endDateComponents)
        
        moneyRecords = realm.objects(MoneyRecord.self)
            .filter("date BETWEEN {%@, %@}", beginDate, endDate)
            .sorted(byKeyPath: "date", ascending: false)
        
        if inFilterState {
            moneyRecords = moneyRecords?.where {
                $0.category.in(selectedSpendingCategories + selectedEarningCategories)
            }.where {
                $0.paymentMethod.in(selectedPaymentMethods)
            }
        }
        
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: todayDate)
        
        if todayComponents.year == currentYearForDay, todayComponents.month == currentMonthForDay, todayComponents.day == currentDayForDay {
            dateLabelBarButtonItem.title = "오늘"
        } else {
            dateLabelBarButtonItem.title = beginDate.dateString
        }
        
        configureLabels()
        tableView.reloadData()
    }
    
    private func updateTableViewForMonth() {
        guard let currentYearForMonth = currentYearForMonth, let currentMonthForMonth = currentMonthForMonth else {
            return
        }
        
        let beginDateComponents = ["year": currentYearForMonth, "month": currentMonthForMonth, "day": 1, "hour": 0, "minute": 0, "second": 0]
        
        let beginDate = makeDate(from: beginDateComponents)
        let lastDayComponents = getLastDayOfMonthComponents(forMonth: currentMonthForMonth)
        
        let endDateComponents = ["year": currentYearForMonth, "month": currentMonthForMonth, "day": lastDayComponents.day!, "hour": 23, "minute": 59, "second": 59]
        
        let endDate = makeDate(from: endDateComponents)
        
        moneyRecords = realm.objects(MoneyRecord.self)
            .filter("date BETWEEN {%@, %@}", beginDate, endDate)
            .sorted(byKeyPath: "date", ascending: false)
        
        if inFilterState {
            moneyRecords = moneyRecords?.where {
                $0.category.in(selectedSpendingCategories + selectedEarningCategories)
            }.where {
                $0.paymentMethod.in(selectedPaymentMethods)
            }
        }
        
        let todayComponents = Calendar.current.dateComponents([.year, .month], from: todayDate)
        
        if todayComponents.year == currentYearForMonth {
            dateLabelBarButtonItem.title = beginDate.monthString
        } else {
            dateLabelBarButtonItem.title = beginDate.yearMonthString
        }
        
        configureLabels()
        tableView.reloadData()
    }
    
    private func updateTableViewForYear() {
        guard let currentYearForYear = currentYearForYear else {
            return
        }
        
        let beginDateComponents = ["year": currentYearForYear, "month": 1, "day": 1, "hour": 0, "minute": 0, "second": 0]
        let endDateComponents = ["year": currentYearForYear, "month": 12, "day": 31, "hour": 23, "minute": 59, "second": 59]
        
        let beginDate = makeDate(from: beginDateComponents)
        let endDate = makeDate(from: endDateComponents)
        
        moneyRecords = realm.objects(MoneyRecord.self)
            .filter("date BETWEEN {%@, %@}", beginDate, endDate)
            .sorted(byKeyPath: "date", ascending: false)
        
        if inFilterState {
            moneyRecords = moneyRecords?.where {
                $0.category.in(selectedSpendingCategories + selectedEarningCategories)
            }.where {
                $0.paymentMethod.in(selectedPaymentMethods)
            }
        }
        
        dateLabelBarButtonItem.title = beginDate.yearString
        
        configureLabels()
        tableView.reloadData()
    }
    
    private func configureLabels() {
        guard let moneyRecords = moneyRecords else { return }
        
        totalRecordLabel.text = "전체 내역 (\(moneyRecords.count)건)"
        
        let spentMoney: Int = moneyRecords
            .filter("type == %@", "지출")
            .sum(ofProperty: "value")
        let earnedMoney: Int = moneyRecords
            .filter("type == %@", "수입")
            .sum(ofProperty: "value")
        
        let total: Int = earnedMoney - spentMoney
        
        spentMoneyLabel.text = "\(NSNumber(value: spentMoney).numberToText!)원"
        earnedMoneyLabel.text = "\(NSNumber(value: earnedMoney).numberToText!)원"
        
        if total == 0 {
            totalLabel.text = "0원"
            totalLabel.textColor = .systemGray2
        } else if total > 0 {
            totalLabel.text = "+\(NSNumber(value: total).numberToText!)원"
            totalLabel.textColor = .systemPurple
        } else {
            totalLabel.text = "\(NSNumber(value: total).numberToText!)원"
            totalLabel.textColor = .systemRed
        }
    }
}

extension MoneyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let moneyRecordsCount = moneyRecords?.count ?? 0
        
        if moneyRecordsCount == 0 {
            emptyView.isHidden = false
            if inFilterState {
                emptyImageView.image = UIImage(systemName: "questionmark.app")
                emptyTextLabel.text = "조건에 맞는 내역이 없어요."
            } else {
                emptyImageView.image = UIImage(systemName: "eject")
                emptyTextLabel.text = """
                                        추가하기 버튼을 눌러
                                        기록을 추가해보세요.
                                        """
            }
        } else {
            emptyView.isHidden = true
        }
        
        return moneyRecordsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MoneyTableViewCell") as? MoneyTableViewCell else { return UITableViewCell() }
        guard let moneyRecord = moneyRecords?[indexPath.row], let category = moneyRecord.category, let paymentMethod = moneyRecord.paymentMethod else { return UITableViewCell() }
        
        cell.symbolImageView.image = UIImage(systemName: category.imageName)
        cell.moneyContentLabel.text = moneyRecord.content
        cell.moneyCategoryMethodLabel.text = "\(category.name) | \(paymentMethod.name) | \(moneyRecord.date.dateString)"
        cell.moneyValueLabel.text = moneyRecord.type == "지출" ? "-\(NSNumber(value: moneyRecord.value).numberToText!)원" : "\(NSNumber(value: moneyRecord.value).numberToText!)원"
        cell.moneyValueLabel.textColor = moneyRecord.type == "지출" ? .systemRed : .systemPurple
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let moneyComposeNavVC = storyboard?.instantiateViewController(withIdentifier: "MoneyRecordNavigationController") as? UINavigationController, let moneyComposeVC = moneyComposeNavVC.children.first as? MoneyComposeViewController else { return }
        
        moneyComposeVC.moneyRecordToEdit = moneyRecords?[indexPath.row]
        
        present(moneyComposeNavVC, animated: true)
    }
}
