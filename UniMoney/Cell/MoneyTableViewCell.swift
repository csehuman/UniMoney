//
//  TableViewCell.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/06.
//

import UIKit

class MoneyTableViewCell: UITableViewCell {
    @IBOutlet weak var symbolImageView: UIImageView!
    @IBOutlet weak var moneyContentLabel: UILabel!
    @IBOutlet weak var moneyCategoryMethodLabel: UILabel!
    @IBOutlet weak var moneyValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
