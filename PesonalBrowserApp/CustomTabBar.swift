//
//  CustomTabBar.swift
//  PesonalBrowserApp
//
//  Created by 上條栞汰 on 2022/07/24.
//

import UIKit
import SnapKit

protocol CustomTabBarDelagate: AnyObject {
    func backButtonDidTap()
    func homeButtonDidTap()
    func forwardButtonDidTap()
}

class CustomTabBar: UIView {
    
    weak var delegate: CustomTabBarDelagate!
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [backButton, homeButton, forwardButton])
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        return button
    }()
    
    lazy var homeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(homeButtonDidTap), for: .touchUpInside)
        button.setImage(UIImage(systemName: "homekit"), for: .normal)
        return button
    }()
    
    lazy var forwardButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(forwardButtonDidTap), for: .touchUpInside )
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.transform = CGAffineTransform(scaleX: -1, y: 1)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    @objc func homeButtonDidTap() {
        delegate.homeButtonDidTap()
    }
    
    @objc func backButtonDidTap() {
        delegate.backButtonDidTap()
    }
    
    @objc func forwardButtonDidTap() {
        delegate.forwardButtonDidTap()
    }
    
    func layout() {
        addSubview(stackView)
        
        
        stackView.snp.makeConstraints{
            $0.left.right.bottom.top.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
