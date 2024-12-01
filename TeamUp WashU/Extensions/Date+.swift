//
//  Date+.swift
//  TeamUp WashU
//
//  Created by 김성태 on 12/1/24.
//

import Foundation

extension Date {
    var str: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: self)
    }
}
