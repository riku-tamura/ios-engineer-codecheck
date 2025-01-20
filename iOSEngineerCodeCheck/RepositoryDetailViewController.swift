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
    
    var repositorySearchController: RepositorySearchViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let selectedIndex = repositorySearchController?.selectedIndex,
              let repository = repositorySearchController?.repositories[selectedIndex] else {
            return
        }
        
        languageLabel.text = "Written in \(repository.language ?? "不明")"
        starsLabel.text = "\(repository.stargazersCount) stars"
        watchersLabel.text = "\(repository.watchersCount) watchers"
        forksLabel.text = "\(repository.forksCount) forks"
        issuesLabel.text = "\(repository.openIssuesCount) open issues"
        loadAvatarImage(for: repository)
    }
    
    func loadAvatarImage(for repository: Repository) {
        guard let owner = repository.owner,
              let imageURL = URL(string: owner.avatarURL) else {
            return
        }
        
        titleLabel.text = repository.fullName
        
        URLSession.shared.dataTask(with: imageURL) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if let error = error { return }
            guard let data = data else { return }
            let image = UIImage(data: data)
            guard let image = image else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }.resume()
    }
}
