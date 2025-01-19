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
        
        languageLabel.text = "Written in \(repository["language"] as? String ?? "")"
        starsLabel.text = "\(repository["stargazers_count"] as? Int ?? 0) stars"
        watchersLabel.text = "\(repository["watchers_count"] as? Int ?? 0) watchers"
        forksLabel.text = "\(repository["forks_count"] as? Int ?? 0) forks"
        issuesLabel.text = "\(repository["open_issues_count"] as? Int ?? 0) open issues"
        loadAvatarImage()
    }
    
    func loadAvatarImage() {
        
        guard let selectedIndex = repositorySearchController?.selectedIndex,
              let repository = repositorySearchController?.repositories[selectedIndex],
              let owner = repository["owner"] as? [String: Any],
              let imageUrlString = owner["avatar_url"] as? String,
              let url = URL(string: imageUrlString) else {
            return
        }
        
        titleLabel.text = repository["full_name"] as? String
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }.resume()
    }
}
