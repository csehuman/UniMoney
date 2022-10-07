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
    
    @IBOutlet weak var moneyTypeSpentButton: UIButton!
    @IBOutlet weak var moneyTypeEarnedButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moneyValueTextField.becomeFirstResponder()
        moneyValueTextField.delegate = self
        
        moneyTypeSpentButton.layer.borderColor = UIColor.systemRed.cgColor
        moneyTypeSpentButton.layer.borderWidth = 0.5
        moneyTypeSpentButton.layer.cornerRadius = 5
        
        moneyTypeEarnedButton.setTitleColor(.systemGray2, for: .normal)
        moneyTypeEarnedButton.layer.borderColor = UIColor.systemGray2.cgColor
        moneyTypeEarnedButton.layer.borderWidth = 0.5
        moneyTypeEarnedButton.layer.cornerRadius = 5
        
        saveButton.layer.cornerRadius = 10
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)
        
        isModalInPresentation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presentationController?.delegate = self
    }
    
    @IBAction func moneyValueEditingChanged(_ sender: UITextField) {
        guard let number = sender.text?.textToNumber, let finalText = number.numberToText else {
            moneyValueWonLabelLeadingConstraint.constant = 25
            return
        }
        
        sender.text = finalText
        
        let font = sender.font ?? UIFont.systemFont(ofSize: 45, weight: .semibold)
        
        let dict = [NSAttributedString.Key.font: font]
        
        let width = finalText.size(withAttributes: dict).width

        moneyValueWonLabelLeadingConstraint.constant = width + 25
    }
    
    @IBAction func moneyTypeSpentButtonTapped(_ sender: UIButton) {
        moneyTypeSpentButton.setTitleColor(.systemRed, for: .normal)
        moneyTypeSpentButton.layer.borderColor = UIColor.systemRed.cgColor
        
        moneyTypeEarnedButton.setTitleColor(.systemGray2, for: .normal)
        moneyTypeEarnedButton.layer.borderColor = UIColor.systemGray2.cgColor
    }
    
    @IBAction func moneyTypeEarnedButtonTapped(_ sender: UIButton) {
        moneyTypeEarnedButton.setTitleColor(.systemGreen, for: .normal)
        moneyTypeEarnedButton.layer.borderColor = UIColor.systemGreen.cgColor
        
        moneyTypeSpentButton.setTitleColor(.systemGray2, for: .normal)
        moneyTypeSpentButton.layer.borderColor = UIColor.systemGray2.cgColor
    }
    
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func touch() {
        self.view.endEditing(true)
    }
}

extension MoneyComposeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moneyValueHelperImageView.alpha = 0.0
        
        let bottomBorderLine = CALayer()
        bottomBorderLine.frame = CGRect(x: 0, y: moneyValueTextField.frame.size.height-1, width: moneyValueTextField.frame.size.width, height: 2)
        bottomBorderLine.backgroundColor = UIColor.systemPurple.cgColor
        moneyValueTextField.layer.addSublayer(bottomBorderLine)
        moneyValueTextField.layer.masksToBounds = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 0 {
            guard string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
                return false
            }
        }
        
        let finalText = NSMutableString(string: moneyValueTextField.text ?? "")
        finalText.replaceCharacters(in: range, with: string)
        finalText.replaceOccurrences(of: ",", with: "", range: NSMakeRange(0, finalText.length))
        
        if finalText.length > 0 && UnicodeScalar(finalText.character(at: 0)) == "0" {
            return false
        }
        
        guard finalText.length <= 10 else {
            let alert = UIAlertController(title: "최대 10자리의 숫자만 입력 가능합니다.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true)
            
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moneyValueHelperImageView.alpha = 1.0
        moneyValueTextField.layer.sublayers = []
    }
}

extension MoneyComposeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("HI")
        let alert = UIAlertController(title: "알림", message: "추가한 내용을 저장할까요?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            // self?.save(action)
            self?.dismiss(animated: true)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] action in
            self?.dismiss(animated: true)
            // self?.close(action)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
