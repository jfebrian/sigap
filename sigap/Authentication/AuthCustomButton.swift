//
//  AuthCustomButton.swift
//  sigap
//
//  Created by Joanda Febrian on 02/04/21.
//

import UIKit

class AuthCustomButton: UIButton {
    
    required init?(coder aDecorder: NSCoder) {
        super.init(coder: aDecorder)
        self.layer.cornerRadius = 5.0
    }
}
