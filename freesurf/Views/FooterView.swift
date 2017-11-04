//
//  FooterView.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/17/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

import UIKit

@objc protocol FooterViewDelegate {
    func didTapAdd()
}

class FooterView: UIView {
    
    let delegate: FooterViewDelegate
    
    init(delegate: FooterViewDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)

        let spitcastButton = UIButton(type: .system)
        spitcastButton.setImage(#imageLiteral(resourceName: "SpitcastLogo"), for: .normal)
        addSubview(spitcastButton)
        spitcastButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(45)
            make.size.equalTo(45)
        }
        spitcastButton.tintColor = UIColor.white
        spitcastButton.addTarget(self, action: #selector(didTapSpitcast), for: .touchUpInside)
        
        let addButton = UIButton(type: .contactAdd)
        addButton.tintColor = UIColor.white
        addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.right.equalTo(-24)
        }
        addButton.addTarget(delegate, action: #selector(delegate.didTapAdd), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapSpitcast() {
        UIApplication.shared.openURL(URL(string: "http://www.spitcast.com")!)
    }

}
