//
//  CategoryEditViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/07.
//

import UIKit
import RealmSwift

class CategoryEditViewController: UIViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    let realm = DataPopulation.shared.realm
    
    var type: String = "수입"
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        categoryCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        categories = realm.objects(Category.self).filter("type == %@", type).sorted(byKeyPath: "order", ascending: true)
        categorySegmentedControl.selectedSegmentIndex = type == "지출" ? 1 : 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.alpha = 0.0
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let categoryAddVC = storyboard?.instantiateViewController(withIdentifier: "CategoryAddViewController") as? CategoryAddViewController else { return }
        categoryAddVC.type = type
        
        navigationController?.pushViewController(categoryAddVC, animated: true)
    }
    
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            categories = realm.objects(Category.self).filter("type == %@", "수입").sorted(byKeyPath: "order", ascending: true)
            type = "수입"
            categoryCollectionView.reloadData()
        } else {
            categories = realm.objects(Category.self).filter("type == %@", "지출").sorted(byKeyPath: "order", ascending: true)
            type = "지출"
            categoryCollectionView.reloadData()
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

extension CategoryEditViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 4) - 20, height: 80)
    }
}

extension CategoryEditViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        
        cell.categoryLabel.text = categories?[indexPath.row].name
        cell.iconImageView.image = UIImage(systemName: categories?[indexPath.row].imageName ?? "")
        
        return cell
    }
}
