//
//  ViewController2.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class RepositoryDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var issuesLabel: UILabel!
    
    var viewModel: RepositoryDetailViewModel? // ViewModel を保持
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.fullName
        languageLabel.text = viewModel.language
        starsLabel.text = viewModel.stars
        watchersLabel.text = viewModel.watchers
        forksLabel.text = viewModel.forks
        issuesLabel.text = viewModel.openIssues
        
        // アバター画像の設定
        setupAvatarImage(from: viewModel.avatarURL)
    }
    
    private func setupAvatarImage(from avatarURL: URL?) {
        if let url = avatarURL {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        self?.imageView.image = image
                    } else {
                        self?.handleImageDownloadError() // 画像ダウンロード失敗時の処理
                    }
                }
            }.resume()
        } else {
            handleImageDownloadError() // 画像URLが無い場合の処理
        }
    }
    
    private func handleImageDownloadError() {
        // 画像ダウンロード失敗時にエラーマークを表示
        imageView.image = UIImage(systemName: "xmark.circle")
        imageView.tintColor = .systemRed
        showImageDownloadError() // エラーメッセージ表示
    }
    
    private func showImageDownloadError() {
        // 画像ダウンロードエラーメッセージを表示
        let errorMessage = UILabel()
        errorMessage.text = "画像のダウンロードに失敗しました"
        errorMessage.textColor = .systemRed
        errorMessage.font = UIFont.systemFont(ofSize: 14)
        errorMessage.textAlignment = .center
        errorMessage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(errorMessage)
        
        // エラーメッセージのレイアウト設定
        NSLayoutConstraint.activate([
            errorMessage.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            errorMessage.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            errorMessage.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.9)
        ])
    }
}
