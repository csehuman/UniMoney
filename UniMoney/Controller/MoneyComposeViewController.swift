//
//  MoneyComposeViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/06.
//

import UIKit
import RealmSwift

class MoneyComposeViewController: UIViewController {
    @IBOutlet weak var moneyValueTextField: UITextField!
    @IBOutlet weak var moneyValueWonLabel: UILabel!
    @IBOutlet weak var moneyValueWonLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var moneyValueHelperImageView: UIImageView!
    
    @IBOutlet weak var moneyTypeSpentButton: UIButton!
    @IBOutlet weak var moneyTypeEarnedButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var moneyContentTextField: UITextField!
    
    @IBOutlet weak var moneyCategoryTextField: UITextField!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var categoryViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var moneyPaymentMethodTextField: UITextField!
    @IBOutlet weak var paymentMethodView: UIView!
    @IBOutlet weak var paymentMethodTableView: UITableView!
    
    @IBOutlet weak var moneyDateTextField: UITextField!
    
    let datePicker = UIDatePicker()
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    var paymentMethods: Results<PaymentMethod>?
    
    var myValue: Int?
    var myType: String = "지출"
    var myContent: String?
    var myCategory: Category?
    var myPaymentMethod: PaymentMethod?
    var myDate: Date?
    
    var moneyRecordToEdit: MoneyRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MoneyValueTextField
        let myView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 50))
        let okButton = UIButton()
        
        myView.addSubview(okButton)
        
        okButton.backgroundColor = .systemPurple
        okButton.setTitle("확인", for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.topAnchor.constraint(equalTo: myView.topAnchor).isActive = true
        okButton.bottomAnchor.constraint(equalTo: myView.bottomAnchor).isActive = true
        okButton.leadingAnchor.constraint(equalTo: myView.leadingAnchor).isActive = true
        okButton.trailingAnchor.constraint(equalTo: myView.trailingAnchor).isActive = true
        
        okButton.addTarget(self, action: #selector(valueOkButtonTapped), for: .touchUpInside)
        
        moneyValueTextField.inputAccessoryView = myView
        
        moneyValueTextField.delegate = self
        
        // MoneyType
        moneyTypeSpentButton.layer.borderColor = UIColor.systemRed.cgColor
        moneyTypeSpentButton.layer.borderWidth = 0.5
        moneyTypeSpentButton.layer.cornerRadius = 5
        
        moneyTypeEarnedButton.setTitleColor(.systemGray2, for: .normal)
        moneyTypeEarnedButton.layer.borderColor = UIColor.systemGray2.cgColor
        moneyTypeEarnedButton.layer.borderWidth = 0.5
        moneyTypeEarnedButton.layer.cornerRadius = 5
        
        // MoneyContentTextField
        moneyContentTextField.delegate = self
        
        // MoneyCategoryTextField
        moneyCategoryTextField.inputView = categoryView
        moneyCategoryTextField.delegate = self
        
        categoryCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        let font = UIFont.systemFont(ofSize: 14)
        
        let categoryToolBar = UIToolbar()
        categoryToolBar.sizeToFit()
        let categoryInfoButton = UIBarButtonItem(title: "카테고리", style: .plain, target: self, action: nil)
        categoryInfoButton.tintColor = .systemGray2
        categoryInfoButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let categoryEditButton = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(categoryEditButtonTapped))
        categoryEditButton.tintColor = .black
        categoryEditButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        categoryToolBar.setItems([categoryInfoButton, spaceButton, categoryEditButton], animated: false)
        moneyCategoryTextField.inputAccessoryView = categoryToolBar
        
        // MoneyPaymentMethodTextField
        moneyPaymentMethodTextField.inputView = paymentMethodView
        moneyPaymentMethodTextField.delegate = self
        
        paymentMethodTableView.dataSource = self
        paymentMethodTableView.delegate = self
        
        let pmToolBar = UIToolbar()
        pmToolBar.sizeToFit()
        let pmInfoButton = UIBarButtonItem(title: "결제수단", style: .plain, target: self, action: nil)
        pmInfoButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        pmInfoButton.tintColor = .systemGray2
        pmToolBar.setItems([pmInfoButton], animated: false)
        moneyPaymentMethodTextField.inputAccessoryView = pmToolBar
        
        // MoneyDateTextField
        datePicker.datePickerMode = .dateAndTime
        datePicker.date = Date()
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.preferredDatePickerStyle = .wheels
        // datePicker.addTarget(self, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let infoButton = UIBarButtonItem(title: "날짜", style: .plain, target: self, action: nil)
        infoButton.tintColor = .systemGray2
        infoButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        let doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(dateDoneButtonTapped))
        doneButton.tintColor = .systemPurple
        doneButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        toolBar.setItems([infoButton, spaceButton, doneButton], animated: false)
        
        moneyDateTextField.text = datePicker.date.dateStringWithTimeAmPm
        moneyDateTextField.inputAccessoryView = toolBar
        moneyDateTextField.inputView = datePicker
        moneyDateTextField.delegate = self
        
//        dateTextField.text = diaryDate?.longDateString
//        dateTextField.delegate = self
        
        saveButton.layer.cornerRadius = 10
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)
        
        categories = realm.objects(Category.self).filter("type == %@", "지출").sorted(byKeyPath: "order", ascending: true)
        paymentMethods = realm.objects(PaymentMethod.self).sorted(byKeyPath: "order", ascending: true)
        
        if let moneyRecordToEdit = moneyRecordToEdit {
            myValue = moneyRecordToEdit.value
            myType = moneyRecordToEdit.type
            myContent = moneyRecordToEdit.content
            myCategory = moneyRecordToEdit.category
            myPaymentMethod = moneyRecordToEdit.paymentMethod
            myDate = moneyRecordToEdit.date
            
            moneyValueTextField.text = "\(moneyRecordToEdit.value)"
            moneyRecordToEdit.type == "지출" ? moneyTypeSpentButtonTapped(nil) : moneyTypeEarnedButtonTapped(nil)
            moneyContentTextField.text = moneyRecordToEdit.content
            moneyCategoryTextField.text = moneyRecordToEdit.category?.name
            moneyPaymentMethodTextField.text = moneyRecordToEdit.paymentMethod?.name
            moneyDateTextField.text = moneyRecordToEdit.date.dateStringWithTimeAmPm
            
            guard let number = moneyValueTextField.text?.textToNumber, let finalText = number.numberToText else {
                moneyValueWonLabelLeadingConstraint.constant = 25
                return
            }
            
            moneyValueTextField.text = finalText
            
            let font = moneyValueTextField.font ?? UIFont.systemFont(ofSize: 45, weight: .semibold)
            
            let dict = [NSAttributedString.Key.font: font]
            
            let width = finalText.size(withAttributes: dict).width

            moneyValueWonLabelLeadingConstraint.constant = width + 25
        } else {
            moneyValueTextField.becomeFirstResponder()
        }
        
        isModalInPresentation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.presentationController?.delegate = self
        navigationController?.navigationBar.isHidden = false
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
    
    @IBAction func moneyTypeSpentButtonTapped(_ sender: UIButton?) {
        moneyTypeSpentButton.setTitleColor(.systemRed, for: .normal)
        moneyTypeSpentButton.layer.borderColor = UIColor.systemRed.cgColor
        
        moneyTypeEarnedButton.setTitleColor(.systemGray2, for: .normal)
        moneyTypeEarnedButton.layer.borderColor = UIColor.systemGray2.cgColor
        
        myType = "지출"
        
        categories = realm.objects(Category.self).filter("type == %@", "지출").sorted(byKeyPath: "order", ascending: true)
        categoryCollectionView.reloadData()
    }
    
    @IBAction func moneyTypeEarnedButtonTapped(_ sender: UIButton?) {
        moneyTypeEarnedButton.setTitleColor(.systemPurple, for: .normal)
        moneyTypeEarnedButton.layer.borderColor = UIColor.systemPurple.cgColor
        
        moneyTypeSpentButton.setTitleColor(.systemGray2, for: .normal)
        moneyTypeSpentButton.layer.borderColor = UIColor.systemGray2.cgColor
        
        myType = "수입"
        
        categories = realm.objects(Category.self).filter("type == %@", "수입").sorted(byKeyPath: "order", ascending: true)
        categoryCollectionView.reloadData()
    }
    
    @objc func valueOkButtonTapped(_ sender: UIButton) {
        moneyValueTextField.resignFirstResponder()
    }
    
    @objc func dateDoneButtonTapped(_ sender: UIButton) {
        moneyDateTextField.text = datePicker.date.dateStringWithTimeAmPm
        myDate = datePicker.date
        moneyDateTextField.resignFirstResponder()
    }
    
    @objc func categoryEditButtonTapped(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "CategoryEditViewController") as? CategoryEditViewController else { return }
        // 내비게이션 설정
        vc.navigationController?.navigationBar.isHidden = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let myValue = myValue, let myContent = myContent, let myCategory = myCategory, let myPaymentMethod = myPaymentMethod, let myDate = myDate else {
            var alertString = ""
            
            if myValue == nil {
                alertString = "금액을 입력해주세요."
            } else if myContent == nil {
                alertString = "내용을 입력해주세요."
            } else if myCategory == nil {
                alertString = "카테고리를 선택해주세요."
            } else if myPaymentMethod == nil {
                alertString = "결제수단을 선택해주세요."
            }
            
            let alert = UIAlertController(title: alertString, message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default)
            alert.addAction(okAction)
            
            if alertString.count > 0 {
                present(alert, animated: true)
            }
            
            return
        }
        
        if let moneyRecordToEdit = moneyRecordToEdit {
            try! realm.write {
                moneyRecordToEdit.setValuesForKeys(["value": myValue, "type": myType, "content": myContent, "date": myDate, "category": myCategory, "paymentMethod": myPaymentMethod])
            }
        } else {
            let newMoneyRecord = MoneyRecord(value: myValue, type: myType, content: myContent, date: myDate, category: myCategory, paymentMethod: myPaymentMethod)
            
            try! realm.write {
                realm.add(newMoneyRecord)
            }
        }
        
        dismiss(animated: true)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc func touch() {
        self.view.endEditing(true)
    }
}

extension MoneyComposeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case moneyValueTextField:
            let bottomBorderLine = CALayer()
            bottomBorderLine.frame = CGRect(x: 0, y: moneyValueTextField.frame.size.height-1, width: moneyValueTextField.frame.size.width, height: 2)
            bottomBorderLine.backgroundColor = UIColor.systemPurple.cgColor
            moneyValueTextField.layer.addSublayer(bottomBorderLine)
            moneyValueTextField.layer.masksToBounds = true
            
            moneyValueHelperImageView.alpha = 0.0
        case moneyCategoryTextField:
            self.categoryView.isHidden = false
        case moneyPaymentMethodTextField:
            self.paymentMethodView.isHidden = false
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case moneyValueTextField:
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
        case moneyCategoryTextField, moneyPaymentMethodTextField, moneyDateTextField:
            return false
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case moneyValueTextField:
            moneyValueHelperImageView.alpha = 1.0
            moneyValueTextField.layer.sublayers = []
            myValue = moneyValueTextField.text?.textToNumber?.intValue
        case moneyContentTextField:
            myContent = moneyContentTextField.text?.count ?? 0 > 0 ? moneyContentTextField.text : nil
        case moneyCategoryTextField:
            categoryView.isHidden = true
        case moneyPaymentMethodTextField:
            paymentMethodView.isHidden = true
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case moneyValueTextField:
            moneyValueTextField.resignFirstResponder()
            return true
        case moneyContentTextField:
            moneyContentTextField.resignFirstResponder()
            moneyCategoryTextField.becomeFirstResponder()
            return true
        default:
            return true
        }
    }
}

extension MoneyComposeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 4) - 20, height: 80)
    }
}

extension MoneyComposeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        
        cell.iconImageView.image = UIImage(systemName: categories?[indexPath.row].imageName ?? "")
        cell.categoryLabel.text = categories?[indexPath.row].name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        myCategory = categories?[indexPath.row]
        moneyCategoryTextField.text = myCategory?.name
        
        moneyCategoryTextField.resignFirstResponder()
        moneyPaymentMethodTextField.becomeFirstResponder()
    }
}

extension MoneyComposeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodCell", for: indexPath)
        
        cell.textLabel?.text = paymentMethods?[indexPath.row].name

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myPaymentMethod = paymentMethods?[indexPath.row]
        moneyPaymentMethodTextField.text = myPaymentMethod?.name
        
        moneyPaymentMethodTextField.resignFirstResponder()
        moneyDateTextField.becomeFirstResponder()
    }
}

extension MoneyComposeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
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
