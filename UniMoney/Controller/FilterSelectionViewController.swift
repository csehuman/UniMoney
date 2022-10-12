//
//  FilterSelectionViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/11.
//

import UIKit
import RealmSwift

class FilterSelectionViewController: UIViewController {
    @IBOutlet weak var filterSelectionTableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    let realm = DataPopulation.shared.realm
    
    var type: String = "지출"
    
    var allSpendingCategories: Results<Category>?
    var allEarningCategories: Results<Category>?
    var allPaymentMethods: Results<PaymentMethod>?

    var selectedSpendingCategories = [Category]()
    var selectedEarningCategories = [Category]()
    var selectedPaymentMethods = [PaymentMethod]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = .white

        filterSelectionTableView.dataSource = self
        filterSelectionTableView.delegate = self
        
        filterSelectionTableView.reloadData()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "buttonSelected"), object: nil, queue: OperationQueue.main) { [weak self] noti in
            guard let self = self else { return }
            
            guard let dic = noti.object as? [String: Any] else { return }
            
            guard let isSelected = dic["isSelected"] as? Bool else { return }
            guard let selectedIndex = dic["selectedIndex"] as? Int else { return }

            if isSelected {
                if selectedIndex == 0 {
                    if self.type == "결제수단" {
                        self.selectedPaymentMethods = Array(self.allPaymentMethods!)
                    } else if self.type == "지출" {
                        self.selectedSpendingCategories = Array(self.allSpendingCategories!)
                    } else if self.type == "수입" {
                        self.selectedEarningCategories = Array(self.allEarningCategories!)
                    }
                } else {
                    if self.type == "결제수단" {
                        guard let pm = self.allPaymentMethods?[selectedIndex-1] else { return }
                        if !self.isContainingPaymentMethod(paymentMethod: pm) {
                            self.selectedPaymentMethods.append(pm)
                        }
                    } else if self.type == "지출" {
                        guard let ct = self.allSpendingCategories?[selectedIndex-1] else { return }
                        if !self.isContainingSpendingCategory(category: ct) {
                            self.selectedSpendingCategories.append(ct)
                        }
                    } else if self.type == "수입" {
                        guard let ct = self.allEarningCategories?[selectedIndex-1] else { return }
                        if !self.isContainingEarningCategory(category: ct) {
                            self.selectedEarningCategories.append(ct)
                        }
                    }
                }
            } else {
                if selectedIndex == 0 {
                    if self.type == "결제수단" {
                        self.selectedPaymentMethods = []
                    } else if self.type == "지출" {
                        self.selectedSpendingCategories = []
                    } else if self.type == "수입" {
                        self.selectedEarningCategories = []
                    }
                } else {
                    if self.type == "결제수단" {
                        guard let pm = self.allPaymentMethods?[selectedIndex-1] else { return }
                        self.selectedPaymentMethods = self.selectedPaymentMethods.filter { $0.name != pm.name }
                    } else if self.type == "지출" {
                        guard let ct = self.allSpendingCategories?[selectedIndex-1] else { return }
                        self.selectedSpendingCategories = self.selectedSpendingCategories.filter { $0.name != ct.name }
                    } else if self.type == "수입" {
                        guard let ct = self.allEarningCategories?[selectedIndex-1] else { return }
                        self.selectedEarningCategories = self.selectedEarningCategories.filter { $0.name != ct.name }
                    }
                }
            }
            
            self.filterSelectionTableView.reloadData()
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        if type == "결제수단" {
            if selectedPaymentMethods.count == 0 {
                let alert = UIAlertController(title: "선택된 결제수단이 없습니다.", message: "1개 이상의 결제수단을 선택하여주세요.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("FilterApplied"), object: ["type": type, "data": selectedPaymentMethods])
                dismiss(animated: true)
            }
        } else if type == "지출" {
            if selectedSpendingCategories.count == 0 {
                let alert = UIAlertController(title: "선택된 지출 카테고리가 없습니다.", message: "1개 이상의 카테고리를 선택하여주세요.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("FilterApplied"), object: ["type": type, "data": selectedSpendingCategories])
                dismiss(animated: true)
            }
        } else if type == "수입" {
            if selectedEarningCategories.count == 0 {
                let alert = UIAlertController(title: "선택된 수입 카테고리가 없습니다.", message: "1개 이상의 카테고리를 선택하여주세요.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("FilterApplied"), object: ["type": type, "data": selectedEarningCategories])
                dismiss(animated: true)
            }
        }
    }
}

extension FilterSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case "결제수단":
            return allPaymentMethods!.count + 1
        case "지출":
            return allSpendingCategories!.count + 1
        case "수입":
            return allEarningCategories!.count + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = filterSelectionTableView.dequeueReusableCell(withIdentifier: "FilterSelectionTableViewCell", for: indexPath) as? FilterSelectionTableViewCell else {
            return UITableViewCell() }
        
        if indexPath.row == 0 {
            cell.filterContentLabel.text = "전체"
            cell.filterContentLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            cell.separatorInset.left = 0
            
            cell.index = 0
            
            print("Here")
            switch type {
            case "결제수단":
                cell.filterContentButton.isSelected = selectedPaymentMethods.count == allPaymentMethods?.count
            case "지출":
                cell.filterContentButton.isSelected = selectedSpendingCategories.count == allSpendingCategories?.count
            case "수입":
                cell.filterContentButton.isSelected = selectedEarningCategories.count == allEarningCategories?.count
            default:
                break
            }
        } else {
            switch type {
            case "결제수단":
                guard let pm = allPaymentMethods?[indexPath.row-1] else { return UITableViewCell() }
                cell.filterContentButton.isSelected = isContainingPaymentMethod(paymentMethod: pm)
                cell.filterContentLabel.text = pm.name
            case "지출":
                guard let ct = allSpendingCategories?[indexPath.row-1] else { return UITableViewCell() }
                cell.filterContentButton.isSelected = isContainingSpendingCategory(category: ct)
                cell.filterContentLabel.text = ct.name
            case "수입":
                guard let ct = allEarningCategories?[indexPath.row-1] else { return UITableViewCell() }
                cell.filterContentButton.isSelected = isContainingEarningCategory(category: ct)
                cell.filterContentLabel.text = ct.name
            default:
                break
            }
            
            cell.index = indexPath.row
            cell.filterContentLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
            cell.separatorInset.left = 15
        }
        
        return cell
    }
}

extension FilterSelectionViewController {
    private func isContainingPaymentMethod(paymentMethod: PaymentMethod) -> Bool {
        if selectedPaymentMethods.contains(where: {
            $0.name == paymentMethod.name
        }) {
            return true
        } else {
            return false
        }
    }
    
    private func isContainingSpendingCategory(category: Category) -> Bool {
        if selectedSpendingCategories.contains(where: {
            $0.name == category.name
        }) {
            return true
        } else {
            return false
        }
    }
    
    private func isContainingEarningCategory(category: Category) -> Bool {
        if selectedEarningCategories.contains(where: {
            $0.name == category.name
        }) {
            return true
        } else {
            return false
        }
    }
}
