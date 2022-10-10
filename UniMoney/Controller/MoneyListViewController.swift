//
//  MoneyListViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/06.
//

import UIKit
import RealmSwift

class MoneyListViewController: UIViewController {

    @IBOutlet weak var spendingView: UIView!
    @IBOutlet weak var earningView: UIView!
    
    @IBOutlet weak var spentMoneyLabel: UILabel!
    @IBOutlet weak var earnedMoneyLabel: UILabel!
    
    @IBOutlet weak var addRecordButton: UIButton!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var moneyRecords: Results<MoneyRecord>?
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        moneyRecords = realm.objects(MoneyRecord.self).sorted(byKeyPath: "date", ascending: false)
        
        if moneyRecords?.count ?? 0 == 0 {
            emptyView.isHidden = false
            tableView.isHidden = true
        } else {
            emptyView.isHidden = true
            tableView.isHidden = false
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MoneyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moneyRecords?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MoneyTableViewCell") as? MoneyTableViewCell else { return UITableViewCell() }
        guard let moneyRecord = moneyRecords?[indexPath.row], let category = moneyRecord.category, let paymentMethod = moneyRecord.paymentMethod else { return UITableViewCell() }
        
        cell.symbolImageView.image = UIImage(systemName: category.imageName)
        cell.moneyContentLabel.text = moneyRecord.content
        cell.moneyCategoryMethodLabel.text = "\(category.name) | \(paymentMethod.name) | \(moneyRecord.date.dateString)"
        cell.moneyValueLabel.text = moneyRecord.type == "지출" ? "-\(moneyRecord.value)원" : "\(moneyRecord.value)원"
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
