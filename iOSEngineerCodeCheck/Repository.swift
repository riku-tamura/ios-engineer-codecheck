//
//  Repository.swift
//  iOSEngineerCodeCheck
//
//  Created by 田村梨恭 on 2025/01/20.
//  Copyright © 2025 YUMEMI Inc. All rights reserved.
//

import Foundation

struct Repository: Codable {
    let fullName: String // リポジトリのフルネーム
    let language: String? // 使用されている言語
    let stargazersCount: Int // stargazerの数
    let watchersCount: Int // watcherの数
    let forksCount: Int // forkの数
    let openIssuesCount: Int // Issuesの数
    let htmlURL: String // リポジトリのURL
    let owner: Owner? // リポジトリのオーナー情報

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case language
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case htmlURL = "html_url"
        case owner
    }
}

struct Owner: Codable {
    let avatarURL: String // アバター画像のURL

    enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
    }
}


struct GitHubSearchResult: Codable {
    let items: [Repository]
}
