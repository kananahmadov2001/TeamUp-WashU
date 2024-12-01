//
//  CalendarAssignmentEmptyTableViewCell.swift
//  TeamUp WashU
//
//  Created by 김성태 on 12/1/24.
//

import UIKit

class CalendarAssignmentEmptyTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
