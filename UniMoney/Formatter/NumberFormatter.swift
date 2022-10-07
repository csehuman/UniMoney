//
//  NumberFormatter.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/07.
//

import Foundation

fileprivate let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.maximumFractionDigits = 0
    return numberFormatter
}()

extension String {
    var textToNumber: NSNumber? {
        let commaRemovedText = self.replacingOccurrences(of: numberFormatter.groupingSeparator, with: "")
 
        return numberFormatter.number(from: commaRemovedText)
    }
}

extension NSNumber {
    var numberToText: String? {
        return numberFormatter.string(from: self)
    }
}
