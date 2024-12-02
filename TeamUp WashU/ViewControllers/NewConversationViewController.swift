//
//  NewConversationViewController.swift
//  TeamUp WashU
//
//  Created by Samuel Gil on 12/1/24.
//

import Foundation
import UIKit
import SwiftUI

class NewConversationViewController: UIViewController, UISearchBarDelegate {
    public var completion: (([String: String]) -> (Void))?
    
    private var users = [[String: String]]()
    
    private var results = [[String: String]]()
    
    private var fetched = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Conversations"
        return searchBar
        
    }()
    
    
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    func search(query: String) {
        if fetched {
            filter(with: query)
        }
        else {
            
        }
    }
    
    func filter(with term: String)  {
        guard fetched else {
            return
        }
        let results: [[String: String]] = self.users.filter({
            guard let email = $0["email"]?.lowercased() else {
                return false
            }
            return email.hasPrefix(term.lowercased())
        })
        
        self.results = results
        updateUI()
        
    }
    
    func updateUI() {
        if results.isEmpty {
            self.tableView.isHidden = true
        }
        else {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["email"]
        return cell
    }
    
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetUserData = results[indexPath.row]
    }
}
