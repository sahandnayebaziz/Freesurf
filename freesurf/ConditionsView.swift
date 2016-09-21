//
//  ConditionsView.swift
//  Freesurf
//
//  Created by Sahand Nayebaziz on 9/20/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

import UIKit

class ConditionsView: UIView, SpotDataDelegate {
    
    let directionLabel = UILabel()
    let periodLabel = UILabel()
    let conditionsLabel = UILabel()
    let windLabel = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        
        let labelsStackView = UIStackView()
        let valuesStackView = UIStackView()
        
        for stackView in [labelsStackView, valuesStackView] {
            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.distribution = .fill
            stackView.spacing = 5
            addSubview(stackView)
        }
        
        labelsStackView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.width.equalTo(100)
        }
        
        valuesStackView.snp.makeConstraints { make in
            make.left.equalTo(120)
            make.top.equalTo(0)
            make.width.equalTo(120)
        }
        
        for metric in ["Direction", "Period", "Condition", "Wind"] {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
            label.textAlignment = .left
            label.text = metric
            label.textColor = Colors.blue
            labelsStackView.addArrangedSubview(label)
        }
        
        for valueLabel in [directionLabel, periodLabel, conditionsLabel, windLabel] {
            valueLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightRegular)
            valueLabel.textAlignment = .left
            valueLabel.textColor = UIColor.white
            valuesStackView.addArrangedSubview(valueLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func did(updateSpot spot: SpotData) {
        conditionsLabel.text = spot.conditionString
    }
    
    func did(updateCounty county: CountyData) {
        directionLabel.text = county.significantSwell?.direction
        periodLabel.text = county.periodString
        windLabel.text = county.windString
    }

}
