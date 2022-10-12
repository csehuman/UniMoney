//
//  FilterSelectionTableViewCell.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/11.
//

import UIKit

class FilterSelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var filterContentLabel: UILabel!
    @IBOutlet weak var filterContentButton: UIButton!
    
    var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    @IBAction func filterContentButtonTapped(_ sender: Any) {
        filterContentButton.isSelected.toggle()
        print(index, filterContentLabel.text)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "buttonSelected"), object: ["selectedIndex": index, "isSelected": filterContentButton.isSelected])
    }
}
