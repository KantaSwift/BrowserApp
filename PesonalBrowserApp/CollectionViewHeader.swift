//
//  CollectionViewHeader.swift
//  PesonalBrowserApp
//
//  Created by 上條栞汰 on 2022/07/27.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {
    
    var sectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(sectionLabel)
        
        [sectionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
         sectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
         sectionLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
         sectionLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1)]
            .forEach { $0.isActive = true }
    }
    
    func setupContent(titleText: String) {
        sectionLabel.text = titleText
    }
}


