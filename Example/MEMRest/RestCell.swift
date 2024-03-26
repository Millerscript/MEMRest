//
//  RestCell.swift
//  MEMRestExample
//
//  Created by Miller Mosquera on 18/03/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class RestCell: UICollectionViewCell {
    
    let titleLbl: UILabel = {
        let style = MRFontStylesManager()
        
        let label = UILabel().newSet()
        label.textColor = .darkGray
        label.font = style.light(size: 16)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 8
        self.contentView.backgroundColor = .lightGray.withAlphaComponent(0.4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setButton(title: String) {
        self.contentView.addSubview(titleLbl)
        
        titleLbl.hookAxis(.horizontal, sameOf: self.contentView)
        titleLbl.hookAxis(.vertical, sameOf: self.contentView)
        titleLbl.text = title
    }
}
