//
//  Assignment.swift
//  TeamUp WashU
//
//  Created by 김성태 on 12/1/24.
//

struct Assignment: Codable {
    var id: String // Unique identifier for Firestore
    var name: String
    var dueDate: String
    var description: String
    var teammates: [String]
    var isCompleted: Bool
    var categories: [String]
}
