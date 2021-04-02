//
//  AuthCustomTextField.swift
//  sigap
//
//  Created by Joanda Febrian on 02/04/21.
//

import UIKit

class AuthCustomTextField: UITextField {

    required init?(coder aDecorder: NSCoder) {
        super.init(coder: aDecorder)
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        
        borderStyle = UITextField.BorderStyle.none
        layer.addSublayer(bottomLine)
         
        attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes:[NSAttributedString.Key.foregroundColor: UIColor(named: "color_labelSecondary")!])
        
    }
}
