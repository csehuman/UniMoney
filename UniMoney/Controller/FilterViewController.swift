//
//  FilterViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/11.
//

import UIKit
import RealmSwift

class FilterViewController: UIViewController {
    
    @IBOutlet weak var spentTextField: UITextField!
    @IBOutlet weak var earnedTextField: UITextField!
    @IBOutlet weak var paymentMethodTextField: UITextField!
    
    @IBOutlet weak var spentCheckBoxButton: UIButton!
    @IBOutlet weak var earnedCheckBoxButton: UIButton!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    let realm = DataPopulation.shared.realm
    
    var allSpendingCategories: Results<Category>?
    var allEarningCategories: Results<Category>?
    var allPaymentMethods: Results<PaymentMethod>?
    
    var selectedSpendingCategories = [Category]()
    var selectedEarningCategories = [Category]()
    var selectedPaymentMethods = [PaymentMethod]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = .white
        
        spentTextField.delegate = self
        earnedTextField.delegate = self
        paymentMethodTextField.delegate = self
        
        configureInitialSettings()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "FilterApplied"), object: nil, queue: OperationQueue.main) { [weak self] noti in
            guard let self = self else { return }
            guard let dict = noti.object as? [String: Any] else { return }
            guard let type = dict["type"] as? String else { return }
            
            if type == "결제수단" {
                guard let data = dict["data"] as? [PaymentMethod] else { return }
                self.selectedPaymentMethods = data
                self.configureTextFieldPlaceholder(type: "결제수단")
            } else if type == "지출" {
                guard let data = dict["data"] as? [Category] else { return }
                self.selectedSpendingCategories = data
                self.configureTextFieldPlaceholder(type: "지출")
            } else if type == "수입" {
                guard let data = dict["data"] as? [Category] else { return }
                self.selectedEarningCategories = data
                self.configureTextFieldPlaceholder(type: "수입")
            }
        }
    }
    
    @IBAction func spentCheckBoxButtonTapped(_ sender: UIButton) {
        let beforeSelectedState = spentCheckBoxButton.isSelected
        spentCheckBoxButton.isSelected.toggle()
        if spentCheckBoxButton.isSelected {
            if !beforeSelectedState {
                selectedSpendingCategories = Array(allSpendingCategories!)
            }
            spentTextField.setPlaceholderColor(.black)
            spentTextField.setBottomBorder(color: .darkGray)
            spentTextField.setImage(color: .darkGray)
        } else {
            if beforeSelectedState {
                selectedSpendingCategories = []
                spentTextField.placeholder = "전체"
            }
            spentTextField.setPlaceholderColor(.lightGray)
            spentTextField.setBottomBorder(color: .lightGray)
            spentTextField.setImage(color: .lightGray)
        }
    }
    
    @IBAction func earnedCheckBoxButtonTapped(_ sender: UIButton) {
        let beforeSelectedState = earnedCheckBoxButton.isSelected
        earnedCheckBoxButton.isSelected.toggle()
        if earnedCheckBoxButton.isSelected {
            if !beforeSelectedState {
                selectedEarningCategories = Array(allEarningCategories!)
            }
            earnedTextField.setPlaceholderColor(.black)
            earnedTextField.setBottomBorder(color: .darkGray)
            earnedTextField.setImage(color: .darkGray)
        } else {
            if beforeSelectedState {
                selectedEarningCategories = []
                earnedTextField.placeholder = "전체"
            }
            earnedTextField.setPlaceholderColor(.lightGray)
            earnedTextField.setBottomBorder(color: .lightGray)
            earnedTextField.setImage(color: .lightGray)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func filterApplyButtonTapped(_ sender: UIButton) {
        let spentChecked = spentCheckBoxButton.isSelected
        let earnedChecked = earnedCheckBoxButton.isSelected
        
        if !spentChecked && !earnedChecked {
            let alert = UIAlertController(title: "1개 이상의 카테고리를 선택해주세요.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "filterToMain"), object: [
                "spentChecked": spentChecked,
                "earnedChecked": earnedChecked,
                "selectedSpendingCategories": selectedSpendingCategories,
                "selectedEarningCategories": selectedEarningCategories,
                "selectedPaymentMethods": selectedPaymentMethods
            ])
            
            dismiss(animated: true)
        }
    }
    
    private func configureTextFieldPlaceholder(type: String) {
        switch type {
        case "결제수단":
            var resultString = ""
            if selectedPaymentMethods.count == allPaymentMethods?.count {
                resultString = "모든 결제수단"
            } else {
                selectedPaymentMethods.forEach {
                    resultString += "\($0.name), "
                }
                
                resultString = String(resultString.dropLast(2))
            }
            paymentMethodTextField.placeholder = resultString
        case "지출":
            var resultString = ""
            if selectedSpendingCategories.count == allSpendingCategories?.count {
                resultString = "전체"
            } else {
                selectedSpendingCategories.forEach {
                    resultString += "\($0.name), "
                }
                
                resultString = String(resultString.dropLast(2))
            }
            spentTextField.placeholder = resultString
        case "수입":
            var resultString = ""
            if selectedEarningCategories.count == allEarningCategories?.count {
                resultString = "전체"
            } else {
                selectedEarningCategories.forEach {
                    resultString += "\($0.name), "
                }
                
                resultString = String(resultString.dropLast(2))
            }
            earnedTextField.placeholder = resultString
        default:
            break
        }
    }
    
    private func configureInitialSettings() {
        if selectedSpendingCategories.count == 0 {
            spentCheckBoxButton.isSelected = false
            spentTextField.placeholder = "전체"
            
            spentTextField.setPlaceholderColor(.lightGray)
            spentTextField.setBottomBorder(color: .lightGray)
            spentTextField.setImage(color: .lightGray)
        } else {
            spentTextField.setPlaceholderColor(.black)
            spentTextField.setBottomBorder(color: .darkGray)
            spentTextField.setImage(color: .darkGray)
            
            spentCheckBoxButton.isSelected = true
            
            configureTextFieldPlaceholder(type: "지출")
        }
        
        if selectedEarningCategories.count == 0 {
            earnedCheckBoxButton.isSelected = false
            earnedTextField.placeholder = "전체"
            
            earnedTextField.setPlaceholderColor(.lightGray)
            earnedTextField.setBottomBorder(color: .lightGray)
            earnedTextField.setImage(color: .lightGray)
        } else {
            earnedTextField.setPlaceholderColor(.black)
            earnedTextField.setBottomBorder(color: .darkGray)
            earnedTextField.setImage(color: .darkGray)
            
            earnedCheckBoxButton.isSelected = true
            
            configureTextFieldPlaceholder(type: "수입")
        }

        paymentMethodTextField.setPlaceholderColor(.black)
        paymentMethodTextField.setBottomBorder(color: .darkGray)
        paymentMethodTextField.setImage(color: .darkGray)
        
        configureTextFieldPlaceholder(type: "결제수단")
    }
}

extension FilterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.endEditing(true)
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "FilterSelectionViewController") as? FilterSelectionViewController else { return }
        
        switch textField {
        case spentTextField:
            if spentCheckBoxButton.isSelected {
                vc.type = "지출"
                vc.allSpendingCategories = allSpendingCategories
                vc.selectedSpendingCategories = selectedSpendingCategories
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        case earnedTextField:
            if earnedCheckBoxButton.isSelected {
                vc.type = "수입"
                vc.allEarningCategories = allEarningCategories
                vc.selectedEarningCategories = selectedEarningCategories
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        case paymentMethodTextField:
            vc.type = "결제수단"
            vc.allPaymentMethods = allPaymentMethods
            vc.selectedPaymentMethods = selectedPaymentMethods
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

extension UITextField {
    func setBottomBorder(color: UIColor) {
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    func setImage(color: UIColor) {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.image = UIImage(systemName: "arrowtriangle.down.circle")
        imageView.tintColor = color
        self.rightView = imageView
        self.rightViewMode = .always
    }
    
    func setPlaceholderColor(_ placeholderColor: UIColor) {
        attributedPlaceholder = NSAttributedString(
            string: self.placeholder ?? "",
            attributes: [
                .foregroundColor: placeholderColor,
                .font: self.font
            ].compactMapValues { $0 }
        )
    }
}
