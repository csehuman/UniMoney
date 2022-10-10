//
//  MoneyRecord.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/09.
//

import Foundation
import RealmSwift

let categoryNumberKey = "categoryNumberKey"
let paymentMethodNumberKey = "paymentMethodNumberKey"

class MoneyRecord: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var value: Int
    @Persisted var type: String
    @Persisted var content: String
    @Persisted var date: Date
    @Persisted var category: Category?
    @Persisted var paymentMethod: PaymentMethod?
    
    convenience init(value: Int, type: String, content: String, date: Date, category: Category, paymentMethod: PaymentMethod) {
        self.init()
        self.value = value
        self.type = type
        self.content = content
        self.date = date
        self.category = category
        self.paymentMethod = paymentMethod
    }
}

class Category: Object {
    @Persisted var name: String
    @Persisted var type: String
    @Persisted var imageName: String
    @Persisted var order: Int?

    convenience init(name: String, type: String, imageName: String) {
        self.init()
        self.name = name
        self.type = type
        self.imageName = imageName
        
        let categoryCount = UserDefaults.standard.integer(forKey: categoryNumberKey)
        
        self.order = categoryCount + 1
        
        UserDefaults.standard.set(self.order, forKey: categoryNumberKey)
    }
}

class PaymentMethod: Object {
    @Persisted var name: String
    @Persisted var order: Int?
    
    convenience init(name: String) {
        self.init()
        self.name = name
        
        let paymentMethodCount = UserDefaults.standard.integer(forKey: paymentMethodNumberKey)
        
        self.order = paymentMethodCount + 1
        
        UserDefaults.standard.set(self.order, forKey: paymentMethodNumberKey)
    }
}
