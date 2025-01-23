//
//  LoadingIndicatorView.swift
//  iOSEngineerCodeCheck
//
//  Created by 田村梨恭 on 2025/01/23.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import UIKit

class LoadingIndicatorView: UIView {
    
    private let indicator = UIActivityIndicatorView(style: .large)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupIndicator()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupIndicator()
    }
    
    // インジケーターと背景の初期設定
    private func setupIndicator() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5) // 半透明の黒背景
        frame = UIScreen.main.bounds // 画面全体を覆うサイズ
        
        indicator.center = center // インジケーターを中央に配置
        indicator.hidesWhenStopped = true // 停止中は非表示
        addSubview(indicator)
    }
    
    // インジケーターのアニメーションを開始し、表示する
    func startAnimating() {
        indicator.startAnimating()
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.addSubview(self)
    }
    
    // インジケーターのアニメーションを停止し、非表示にする
    func stopAnimating() {
        indicator.stopAnimating()
        self.removeFromSuperview()
    }
}

