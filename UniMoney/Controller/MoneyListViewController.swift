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
    var tokens: [NSObjectProtocol]?
    
    var moneyRecords: Results<MoneyRecord>?
    
    var allSpendingCategories: Results<Category>?
    var allEarningCategories: Results<Category>?
    var allPaymentMethods: Results<PaymentMethod>?
    
    var selectedSpendingCategories = [Category]()
    var selectedEarningCategories = [Category]()
    var selectedPaymentMethods = [PaymentMethod]()
    
    var inFilterState: Bool = false
    
    let realm = DataManager.shared.realm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInitialViewAndButton()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let nibName = UINib(nibName: "MoneyTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "MoneyTableViewCell")
        
        allSpendingCategories = DataManager.shared.getAllSpendingCategories()
        allEarningCategories = DataManager.shared.getAllEarningCategories()
        allPaymentMethods = DataManager.shared.getAllPaymentMethods()
        
        selectedSpendingCategories = Array(allSpendingCategories!)
        selectedEarningCategories = Array(allEarningCategories!)
        selectedPaymentMethods = Array(allPaymentMethods!)
        
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
            .sorted(byKeyPath: "date", ascending: false)
        
        configureLabels()
        
        token = NotificationCenter.default.addObserver(forName: NSNotification.Name("moneyRecordSaved"), object: nil, queue: OperationQueue.main) { [weak self] noti in
            self?.configureLabels()
            self?.tableView.reloadData()
        }
        tokens?.append(token!)
        
        token = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "filterToMain"), object: nil, queue: OperationQueue.main) { [weak self] noti in
            guard let self = self else { return }
            
            guard let dict = noti.object as? [String: Any] else { return }
            guard let spentChecked = dict["spentChecked"] as? Bool else { return }
            guard let earnedChecked = dict["earnedChecked"] as? Bool else { return }
            guard let spendingCategories = dict["selectedSpendingCategories"] as? [Category] else { return }
            guard let earningCategories = dict["selectedEarningCategories"] as? [Category] else { return }
            guard let paymentMethods = dict["selectedPaymentMethods"] as? [PaymentMethod] else { return }
            
            self.selectedSpendingCategories = spendingCategories
            self.selectedEarningCategories = earningCategories
            self.selectedPaymentMethods = paymentMethods
            
            self.inFilterState = true
            
            if !spentChecked {
                self.selectedSpendingCategories = []
                self.filterButton.setTitle("수입 | 결제수단", for: .normal)
            } else if !earnedChecked {
                self.selectedEarningCategories = []
                self.filterButton.setTitle("지출 | 결제수단", for: .normal)
            } else {
                self.filterButton.setTitle("지출 | 수입 | 결제수단", for: .normal)
            }
            
            self.filterCancelButton.isHidden = false
            
            self.tableView.reloadData()
            self.configureLabels()
        }
        tokens?.append(token!)
    }
    
    deinit {
        if let tokens = tokens {
            for token in tokens {
                NotificationCenter.default.removeObserver(token)
            }
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
        case 1:
            currentDateMode = .month
        case 2:
            currentDateMode = .year
        default:
            break
        }
        
        tableView.reloadData()
        configureLabels()
    }
    
    @IBAction func filterCancelButtonTapped(_ sender: UIButton) {
        filterCancelButton.isHidden = true
        filterButton.setTitle("필터", for: .normal)
        
        inFilterState = false
        
        selectedSpendingCategories = Array(allSpendingCategories!)
        selectedEarningCategories = Array(allEarningCategories!)
        selectedPaymentMethods = Array(allPaymentMethods!)
        
        tableView.reloadData()
        configureLabels()
    }
    
    
    @IBAction func previousDateButtonTapped(_ sender: UIBarButtonItem) {
        if inFilterState {
            showFilterAlert()
        } else {
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
            tableView.reloadData()
            configureLabels()
        }
    }
    
    @IBAction func nextDateButtonTapped(_ sender: UIBarButtonItem) {
        if inFilterState {
            showFilterAlert()
        } else {
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
            
            tableView.reloadData()
            configureLabels()
        }
    }
    
    private func getDataForDay(year: Int, month: Int, day: Int) {
        let dateRange = DateManager.shared.getDayRange(year: year, month: month, day: day)
        
        let beginDate = dateRange.0
        let endDate = dateRange.1
        
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
    }
    
    private func getDataForMonth(year: Int, month: Int) {
        let dateRange = DateManager.shared.getMonthRange(year: year, month: month)
        
        let beginDate = dateRange.0
        let endDate = dateRange.1
        
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
    }
    
    private func getDataForYear(year: Int) {
        let dateRange = DateManager.shared.getYearRange(year: year)
        
        let beginDate = dateRange.0
        let endDate = dateRange.1
        
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
    }
    
    private func showFilterAlert() {
        let alert = UIAlertController(title: "필터 해제 후 기간을 변경해주세요.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
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
        
        switch currentDateMode {
        case .year:
            let date = DateManager.shared.getDate(year: currentYearForYear!)
            dateLabelBarButtonItem.title = date.yearString
        case .month:
            let todayComponents = DateManager.shared.getTodayDate()
            let date = DateManager.shared.getDate(year: currentYearForMonth!, month: currentMonthForMonth!)
            
            if todayComponents.0 == currentYearForMonth {
                dateLabelBarButtonItem.title = date.monthString
            } else {
                dateLabelBarButtonItem.title = date.yearMonthString
            }
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
        }
    }
    
    private func configureInitialViewAndButton() {
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
        }
    }
}

extension MoneyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentDateMode {
        case .year:
            getDataForYear(year: currentYearForYear!)
        case .month:
            getDataForMonth(year: currentYearForMonth!, month: currentMonthForMonth!)
        case .day:
            getDataForDay(year: currentYearForDay!, month: currentMonthForDay!, day: currentDayForDay!)
        }
        
        
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (action, view, completion) in
            guard let moneyRecord = self.moneyRecords?[indexPath.row] else { return }
            try! self.realm.write {
                self.realm.delete(moneyRecord)
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        // cell 전체 swipe시 첫번째 action 실행
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
