//
//  RepositoryDetailViewModel.swift
//  iOSEngineerCodeCheck
//
//  Created by 田村梨恭 on 2025/01/23.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import UIKit

class RepositoryDetailViewModel {
    private let repository: Repository
    
    // 初期化
    init(repository: Repository) {
        self.repository = repository
    }
    
    // リポジトリ名
    var fullName: String {
        return repository.fullName
    }
    
    // プログラミング言語
    var language: String {
        return "言語: \(repository.language ?? "不明")"
    }
    
    // スター数
    var stars: String {
        return "\(repository.stargazersCount) stars"
    }
    
    // ウォッチャー数
    var watchers: String {
        return "\(repository.watchersCount) watchers"
    }
    
    // フォーク数
    var forks: String {
        return "\(repository.forksCount) forks"
    }
    
    // オープンな issue 数
    var openIssues: String {
        return "\(repository.openIssuesCount) open issues"
    }
    // リポジトリの URL
    var htmlURL: String {
        return repository.htmlURL
    }
    
    // アバター画像の URL
    var avatarURL: URL? {
        guard let avatarURL = repository.owner?.avatarURL else { return nil }
        return URL(string: avatarURL)
    }
}
