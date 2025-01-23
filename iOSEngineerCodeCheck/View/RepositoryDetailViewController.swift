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
    
    private func setupAvatarImage(from url: URL?) {
        guard let url = url else { return }
        
        // 非同期で画像を取得
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self?.imageView.image = image
                } else {

                }
            }
        }.resume()
    }
}
