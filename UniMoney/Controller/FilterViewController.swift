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
        
        spentTextField.setBottomBorder(color: .systemGray4)
        earnedTextField.setBottomBorder(color: .systemGray4)
        paymentMethodTextField.setBottomBorder(color: .systemGray4)
        
        spentTextField.setImage()
        earnedTextField.setImage()
        paymentMethodTextField.setImage()
        
        spentCheckBoxButton.isSelected = true
        earnedCheckBoxButton.isSelected = true
        
        allSpendingCategories = realm.objects(Category.self).filter("type == %@", "지출").sorted(byKeyPath: "order", ascending: true)
        allEarningCategories = realm.objects(Category.self).filter("type == %@", "수입").sorted(byKeyPath: "order", ascending: true)
        allPaymentMethods = realm.objects(PaymentMethod.self).sorted(byKeyPath: "order", ascending: true)
        
        selectedSpendingCategories = Array(allSpendingCategories!)
        selectedEarningCategories = Array(allEarningCategories!)
        selectedPaymentMethods = Array(allPaymentMethods!)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "FilterApplied"), object: nil, queue: OperationQueue.main) { [weak self] noti in
            guard let self = self else { return }
            guard let dict = noti.object as? [String: Any] else { return }
            guard let type = dict["type"] as? String else { return }
            
            if type == "결제수단" {
                guard let data = dict["data"] as? [PaymentMethod] else { return }
                self.selectedPaymentMethods = data
            } else if type == "지출" {
                guard let data = dict["data"] as? [Category] else { return }
                self.selectedSpendingCategories = data
                print(self.selectedSpendingCategories.count)
            } else if type == "수입" {
                guard let data = dict["data"] as? [Category] else { return }
                self.selectedEarningCategories = data
            }
        }
    }
    
    @IBAction func spentCheckBoxButtonTapped(_ sender: UIButton) {
        spentCheckBoxButton.isSelected.toggle()
    }
    
    @IBAction func earnedCheckBoxButtonTapped(_ sender: UIButton) {
        earnedCheckBoxButton.isSelected.toggle()
    }
    
}

extension FilterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "FilterSelectionViewController") as? FilterSelectionViewController else { return }
        
        switch textField {
        case spentTextField:
            vc.type = "지출"
            vc.allSpendingCategories = allSpendingCategories
            vc.selectedSpendingCategories = selectedSpendingCategories
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        case earnedTextField:
            vc.type = "수입"
            vc.allEarningCategories = allEarningCategories
            vc.selectedEarningCategories = selectedEarningCategories
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
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
    
    func setImage() {
        print("Hi")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.image = UIImage(systemName: "arrowtriangle.down.circle")
        imageView.tintColor = .lightGray
        self.rightView = imageView
        self.rightViewMode = .always
    }
}
