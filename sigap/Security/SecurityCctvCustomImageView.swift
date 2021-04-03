//
//  SecurityCctvCustomView.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit

class SecurityCctvCustomImageView: UIImageView {

    private lazy var pulse: CAGradientLayer = {
        let g = CAGradientLayer()
        g.type = .radial
        g.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        let center = CGPoint(x: 0.5, y: 0.5)
        g.startPoint = center
        let radius = 1.5
        g.endPoint = CGPoint(x: radius, y: radius)
        layer.addSublayer(g)
        return g
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        pulse.frame = bounds
        pulse.cornerRadius = 10.0
        layer.cornerRadius = 10.0
    }


}
