//
//  HeightAndTemperatureView.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/20/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class HeightAndTemperatureView: UIView, SpotDataDelegate {
    
    let temperatureLabel = UILabel()
    let heightLabel = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .lastBaseline
        stackView.spacing = 10
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.size.equalTo(self)
            make.center.equalTo(self)
        }
        
        stackView.addArrangedSubview(temperatureLabel)
        temperatureLabel.font = UIFont.systemFont(ofSize: 48, weight: UIFontWeightThin)
        temperatureLabel.textColor = Colors.blue
        temperatureLabel.textAlignment = .left
        
        stackView.addArrangedSubview(heightLabel)
        heightLabel.font = UIFont.systemFont(ofSize: 72, weight: UIFontWeightThin)
        heightLabel.textColor = Colors.blue
        heightLabel.textAlignment = .right
    }
    
    func did(updateSpot spot: SpotData) {
        heightLabel.text = spot.heightRangeString
    }
    
    func did(updateCounty county: CountyData) {
        temperatureLabel.text = county.waterTemperatureString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
