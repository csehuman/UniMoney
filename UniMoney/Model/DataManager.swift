//
//  DataManager.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/14.
//

import Foundation
import RealmSwift

class DataManager {
    static let shared = DataManager()
    
    private init() { }
    
    let realm = try! Realm()
    
    func getAllSpendingCategories() -> Results<Category> {
        return realm.objects(Category.self).filter("type == %@", "지출").sorted(byKeyPath: "order", ascending: true)
    }
    
    func getAllEarningCategories() -> Results<Category> {
        return realm.objects(Category.self).filter("type == %@", "수입").sorted(byKeyPath: "order", ascending: true)
    }
    
    func getAllPaymentMethods() -> Results<PaymentMethod> {
        return realm.objects(PaymentMethod.self).sorted(byKeyPath: "order", ascending: true)
    }
}
