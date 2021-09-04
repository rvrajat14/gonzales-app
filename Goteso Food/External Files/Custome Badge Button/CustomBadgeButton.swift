//
//  CustomBadgeButton.swift
//  Laundrit
//
//  Created by Kishore on 10/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class CustomBadgeButton: UIButton {
        var badgeValue : String! = "" {
            didSet {
                self.layoutSubviews()
            }
        }
        
        override init(frame :CGRect)  {
            // Initialize the UIView
            super.init(frame : frame)
            
            self.awakeFromNib()
        }
        
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            self.awakeFromNib()
        }
        
        
        override func awakeFromNib()
        {
            self.drawBadgeLayer()
        }
        
        var badgeLayer :CAShapeLayer!
        func drawBadgeLayer() {
            
            if self.badgeLayer != nil {
                self.badgeLayer.removeFromSuperlayer()
            }
            
            // Omit layer if text is nil
            if self.badgeValue == nil || self.badgeValue.characters.count == 0 {
                return
            }
            
            //! Initial label text layer
            let labelText = CATextLayer()
            labelText.contentsScale = UIScreen.main.scale
            labelText.string = self.badgeValue.uppercased()
            labelText.fontSize = 12.0
            labelText.font = UIFont(name: SEMIBOLD, size: 12)
            labelText.alignmentMode = kCAAlignmentCenter
            labelText.foregroundColor = UIColor.white.cgColor
            let labelString = self.badgeValue.uppercased() as String?
            let labelFont = UIFont(name: SEMIBOLD, size: 12)
            let attributes = [NSAttributedStringKey.font:labelFont!]
            let w = 16.0
            let h = 16.0  // fixed height
            let textWidth = round(16.0)
            labelText.frame = CGRect(x: CGFloat(7), y: CGFloat(0), width: CGFloat(textWidth), height: CGFloat(h))
                
               // CGRect(x: 0, y: 0, width: textWidth, height: CGFloat(h))
            
            //! Initialize outline, set frame and color
            let shapeLayer = CAShapeLayer()
            shapeLayer.contentsScale = UIScreen.main.scale
            let frame : CGRect = labelText.frame
            let cornerRadius = h/2
            let borderInset = CGFloat(-1.0)
            let aPath = UIBezierPath(roundedRect: frame.insetBy(dx: borderInset, dy: borderInset), cornerRadius: CGFloat(cornerRadius))
            
            shapeLayer.path = aPath.cgPath
            shapeLayer.fillColor = UIColor.red.cgColor
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.lineWidth = 0.5
            
            shapeLayer.insertSublayer(labelText, at: 0)
            
            shapeLayer.frame = shapeLayer.frame.offsetBy(dx: CGFloat(w*0.9), dy: 0.0)
            
            self.layer.insertSublayer(shapeLayer, at: 999)
            self.layer.masksToBounds = false
            self.badgeLayer = shapeLayer
            
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.drawBadgeLayer()
            self.setNeedsDisplay()
        }
        
}
