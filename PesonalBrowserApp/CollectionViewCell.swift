//
//  CollectionViewCell.swift
//  PesonalBrowserApp
//
//  Created by 上條栞汰 on 2022/07/27.
//

import UIKit
import SnapKit

class CollectionViewCell: UICollectionViewCell {
    
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        addSubview(label)
        
        label.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
    }
    
    func setupContent(nameLabel: String) {
        label.text = nameLabel
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
