//
//  CalendarAssignmentTableViewCell.swift
//  TeamUp WashU
//
//  Created by 김성태 on 12/1/24.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet var checkImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func setData(assignment: Assignment) {
        print("\(type(of: self)) - \(#function)")

        checkImageView.image = assignment.isCompleted ? .init(systemName: "checkmark.square.fill") : .init(systemName: "square")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
