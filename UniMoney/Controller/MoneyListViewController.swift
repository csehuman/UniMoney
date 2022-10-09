//
//  MoneyListViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/06.
//

import UIKit

class MoneyListViewController: UIViewController {

    @IBOutlet weak var spendingView: UIView!
    @IBOutlet weak var earningView: UIView!
    
    @IBOutlet weak var spentMoneyLabel: UILabel!
    @IBOutlet weak var earnedMoneyLabel: UILabel!
    
    @IBOutlet weak var addRecordButton: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
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
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MoneyTableViewCell") as? MoneyTableViewCell else { return UITableViewCell() }
        cell.symbolImageView.image = UIImage(systemName: "fork.knife")
        cell.moneyContentLabel.text = "점심 - 돈까스 김밥"
        cell.moneyCategoryMethodLabel.text = "식비 | 현금 | 10월 5일"
        cell.moneyValueLabel.text = "-5000원"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
