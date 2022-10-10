//
//  CategoryAddViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/10.
//

import UIKit
import RealmSwift

class CategoryAddViewController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var iconSelectionView: UIView!
    @IBOutlet weak var iconImageCollectionView: UICollectionView!
    
    @IBOutlet weak var dimmingView: UIView!
    
    let myIconData = [
        "pencil", "arrowshape.turn.up.backward.circle", "book", "paperplane", "person.fill",
        "globe.americas.fill", "sun.min", "flame", "cursorarrow.rays", "heart.circle", "mustache",
        "icloud", "camera", "gearshape", "cart", "paintbrush", "bandange", "house", "building",
        "lock", "bolt.car", "bed.double", "tortoise", "leaf", "hourglass", "fork.knife.circle"
    ]
    
    var type: String = "지출"
    var imageName = ""
    
    let realm = DataPopulation.shared.realm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconImageCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        iconImageCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        iconImageCollectionView.dataSource = self
        iconImageCollectionView.delegate = self
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        iconImageView.addGestureRecognizer(recognizer)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let text = categoryTextField.text else { return }

        let newCategory = Category(name: text, type: type, imageName: imageName)
        
        try! realm.write {
            realm.add(newCategory)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func iconSelectionCloseButtonTapped(_ sender: Any) {
        iconSelectionView.isHidden = true
        dimmingView.isHidden = true
    }
    
    @objc func touch() {
        iconSelectionView.isHidden = false
        dimmingView.isHidden = false
    }
}

extension CategoryAddViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 4) - 20, height: 80)
    }
}

extension CategoryAddViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myIconData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        
        cell.iconImageView.image = UIImage(systemName: myIconData[indexPath.row])
        cell.categoryLabel.text = ""
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        iconSelectionView.isHidden = true
        dimmingView.isHidden = true
        
        imageName = myIconData[indexPath.row]
        iconImageView.image = UIImage(systemName: imageName)
    }
}
