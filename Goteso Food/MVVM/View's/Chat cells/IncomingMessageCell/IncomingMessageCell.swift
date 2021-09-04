//
//  IncomingMessageCell.swift
//  RealTimeChatWithNodeJsDemo
//
//  Created by Apple on 24/07/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class IncomingMessageCell: UITableViewCell {

   // @IBOutlet weak var userNameLbl: EdgeInsetLabel!
    @IBOutlet weak var lblHeightConstraint: NSLayoutConstraint!
  //  @IBOutlet weak var conatinerHeightConstraint: NSLayoutConstraint!
       @IBOutlet var shadowV: [UIView]!
    @IBOutlet weak var containerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerV: UIView!
    @IBOutlet weak var messageLbl: EdgeInsetLabel!
    @IBOutlet weak var cellTopLblHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var cellTopLbl: UILabel!
 //Users/apple/Desktop/Simer/Demo Code/RealTimeChatWithNodeJsDemo/RealTimeChatWithNodeJsDemo/Chat Cells/IncomingMessageCell.swift/Users/apple/Desktop/Simer/Demo Code/RealTimeChatWithNodeJsDemo/RealTimeChatWithNodeJsDemo/Chat Cells/IncomingMessageCell.xib/   @IBOutlet weak var txtV: UITextView!
    @IBOutlet weak var cellBottomLbl: UILabel!
    @IBOutlet weak var cellBottomLblHeightConstraints: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerV.leftBottomCorner()
        DispatchQueue.main.async {
            for v in self.shadowV {
                SHADOW_EFFECT.makeBottomShadow(forView: v, shadowHeight: 1, color: .lightGray, top_shadow: false,left: true,bottom: true,right: true,cornerRadius:1)
                
            }
            
        }
        self.messageLbl.textInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.containerV.leftBottomCorner()
        DispatchQueue.main.async {
            for v in self.shadowV {
                SHADOW_EFFECT.makeBottomShadow(forView: v, shadowHeight: 1, color: .lightGray, top_shadow: false,left: true,bottom: true,right: true,cornerRadius:1)
                
            }
            
        }
    containerWidthConstraint.constant = 0.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      //  self.txtV.contentInset = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        
        // Configure the view for the selected state
    }
    
}
