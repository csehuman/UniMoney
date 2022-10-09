//
//  MoneyRecord.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/09.
//

import Foundation
import RealmSwift

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
    
    static var count: Int = 0
    
    convenience init(name: String, type: String, imageName: String) {
        self.init()
        self.name = name
        self.type = type
        self.imageName = imageName
        self.order = Category.count + 1
        Category.count += 1
    }
}

class PaymentMethod: Object {
    @Persisted var name: String
    @Persisted var order: Int?
    
    static var count: Int = 0
    
    convenience init(name: String) {
        self.init()
        self.name = name
        self.order = PaymentMethod.count + 1
        PaymentMethod.count += 1
    }
}
