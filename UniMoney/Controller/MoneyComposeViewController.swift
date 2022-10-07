//
//  MoneyComposeViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/06.
//

import UIKit

class MoneyComposeViewController: UIViewController {
    @IBOutlet weak var moneyValueTextField: UITextField!
    @IBOutlet weak var moneyValueWonLabel: UILabel!
    @IBOutlet weak var moneyValueWonLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var moneyValueHelperImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moneyValueTextField.becomeFirstResponder()
        moneyValueTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension MoneyComposeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // moneyValueHelperView.alpha = 0.0
        moneyValueHelperImageView.alpha = 0.0
        
        let bottomBorderLine = CALayer()
        bottomBorderLine.frame = CGRect(x: 0, y: moneyValueTextField.frame.size.height-1, width: moneyValueTextField.frame.size.width, height: 2)
        bottomBorderLine.backgroundColor = UIColor.systemPurple.cgColor
        moneyValueTextField.layer.addSublayer(bottomBorderLine)
        moneyValueTextField.layer.masksToBounds = true
        
//        moneyValueTextField.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: moneyValueWonLabel.bounds.width))
        
//        moneyValueTextFieldTrailingConstraint.isActive = false
//        moneyValueTextFieldTrailingConstraint = moneyValueTextField.trailingAnchor.constraint(equalTo: moneyValueWonLabel.leadingAnchor, constant: 0)
//        moneyValueTextFieldTrailingConstraint.isActive = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 0 {
            guard string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
                return false
            }
        }
        
        let finalText = NSMutableString(string: moneyValueTextField.text ?? "")
        finalText.replaceCharacters(in: range, with: string)
        
        let font = textField.font ?? UIFont.systemFont(ofSize: 45, weight: .semibold)
        
        let dict = [NSAttributedString.Key.font: font]
        
        let width = finalText.size(withAttributes: dict).width
        
        moneyValueWonLabelLeadingConstraint.constant = width + 25
        
        return true
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // moneyValueTextField.rightViewMode = .never
        moneyValueTextField.layer.sublayers = []
        moneyValueHelperImageView.alpha = 1.0
    }
}
