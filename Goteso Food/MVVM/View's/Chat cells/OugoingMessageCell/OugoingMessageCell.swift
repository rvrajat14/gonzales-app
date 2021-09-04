//
//  OugoingMessageCell.swift
//  RealTimeChatWithNodeJsDemo
//
//  Created by Apple on 24/07/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class OugoingMessageCell: UITableViewCell {

    //@IBOutlet weak var conatinerHeightConstraint: NSLayoutConstraint!
    //@IBOutlet weak var userNameLbl: EdgeInsetLabel!

     @IBOutlet weak var lblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerWidthConstraint: NSLayoutConstraint!
   
    @IBOutlet var shadowV: [UIView]!
    @IBOutlet weak var containerV: UIView!
    @IBOutlet weak var cellTopLblHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var cellTopLbl: UILabel!
  //  @IBOutlet weak var txtV: UITextView!
    @IBOutlet weak var messageLbl: EdgeInsetLabel!
    @IBOutlet weak var cellBottomLbl: UILabel!
    @IBOutlet weak var cellBottomLblHeightConstraints: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     self.containerV.rightBottomCorner()
        
       
        
        DispatchQueue.main.async {
            for v in self.shadowV {
                SHADOW_EFFECT.makeBottomShadow(forView: v, shadowHeight: 1, color: .lightGray, top_shadow: false,left: true,bottom: true,right: true,cornerRadius:1)
                
            }
            
        }
      
       // self.containerV.layer.cornerRadius = 10
       // self.containerV.clipsToBounds = true
        self.messageLbl.textInsets = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.containerV.rightBottomCorner()
        DispatchQueue.main.async {
            for v in self.shadowV {
                SHADOW_EFFECT.makeBottomShadow(forView: v, shadowHeight: 1, color: .lightGray, top_shadow: false,left: true,bottom: true,right: true,cornerRadius:1)
                
            }
            
        }
        containerWidthConstraint.constant = 0.0
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       // self.txtV.contentInset = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        // Configure the view for the selected state
       
    }
    
}
