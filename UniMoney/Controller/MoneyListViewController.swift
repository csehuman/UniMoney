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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spendingView.layer.cornerRadius = 5
        spendingView.backgroundColor = .white
        spendingView.layer.borderColor = UIColor.systemRed.cgColor
        spendingView.layer.borderWidth = 0.5
        
        spentMoneyLabel.textColor = .systemRed
        
        earningView.layer.cornerRadius = 5
        earningView.backgroundColor = .white
        earningView.layer.borderColor = UIColor.systemGreen.cgColor
        earningView.layer.borderWidth = 0.5
        
        earnedMoneyLabel.textColor = .systemGreen
        
        
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
