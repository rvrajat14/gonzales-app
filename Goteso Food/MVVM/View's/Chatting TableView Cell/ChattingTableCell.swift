//
//  ChattingTableCell.swift
//  My MM
//
//  Created by Kishore on 04/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class ChattingTableCell: UITableViewCell {

    @IBOutlet weak var receiverUserName: UILabel!
    @IBOutlet weak var senderUserName: UILabel!
    @IBOutlet weak var receiverDateLbl: UILabel!
    @IBOutlet weak var senderDateLbl: UILabel!
    @IBOutlet weak var receiverViewWidth: NSLayoutConstraint!
    @IBOutlet weak var senderViewWidth: NSLayoutConstraint!
    @IBOutlet weak var receiverSubView: UIView!
    @IBOutlet weak var senderSubView: UIView!
    @IBOutlet weak var receiverMsgLbl: UILabel!
    @IBOutlet weak var receiverView: UIView!
    @IBOutlet weak var senderMsgLbl: UILabel!
    @IBOutlet weak var senderView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        senderViewWidth.constant = 0.0
        receiverViewWidth.constant = 0.0
    }
    
}
