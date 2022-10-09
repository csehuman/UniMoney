//
//  DataPopulationInitialLaunch.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/09.
//

import Foundation
import RealmSwift

class DataPopulation {
    static let shared = DataPopulation()
    private init() {}
    
    let realm = try! Realm()
    
    func setUpCategories() {
        let initialCategories = [
            ("식비", "지출", "fork.knife"), ("카페/간식", "지출", "cup.and.saucer"), ("술/유흥", "지출", "crown"), ("생활", "지출", "cart"),
            ("온라인쇼핑", "지출", "bag"), ("패션/쇼핑", "지출", "tshirt"), ("뷰티/미용", "지출", "mouth"), ("교통", "지출", "tram"),
            ("자동차", "지출", "car"), ("주거/통신", "지출", "house"), ("의료/건강", "지출", "cross.case"), ("금융", "지출", "wonsign.circle"),
            ("문화/여가", "지출", "ticket"), ("여행/숙박", "지출", "airplane.departure"), ("교육/학습", "지출", "graduationcap"), ("자녀/육아", "지출", "person.2"),
            ("반려동물", "지출", "pawprint"), ("경조/선물", "지출", "gift"),
            ("급여", "수입", ""), ("용돈", "수입", ""), ("금융수입", "수입", ""), ("사업수입", "수입", ""), ("기타수입", "수입", "")
        ]
        
        initialCategories.forEach {
            let newCategory = Category(name: $0.0, type: $0.1, imageName: $0.2)
            try! realm.write {
                realm.add(newCategory)
            }
        }
    }
    
    func setUpPaymentMethods() {
        let initialPaymentMethods = ["현금", "계좌이체", "신용/체크카드"]
        
        initialPaymentMethods.forEach {
            let newPaymentMethod = PaymentMethod(name: $0)
            try! realm.write {
                realm.add(newPaymentMethod)
            }
        }
    }
}

// bolt.circle
// giftcard
