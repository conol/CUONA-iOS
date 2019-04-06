//
//  Define.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/06.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

struct Constants
{
    static let foverEventAction = "favor"        // Favorを使用可能なCUONAに書き込まれているkey
    static let favorEventToken = "UXbfYJ6SXm8G"  // Favorのイベントトークン
}

struct Message
{
    static let cuonaScan = "CUONAにタッチしてください"    // CUONAスキャンダイアログのメッセージ
}

struct ErrorCode
{
    static let faildToReadCuona    = 100000    // CUONA読み込みに失敗
    static let notExistEventAction = 100100    // Favorイベントアクションが存在しない
    static let invalidEventToken   = 100101    // Favorトークンが正しくない
}

struct ErrorType {
    static let cuonaTouchError = "CuonaTouchError"  // CUONAタッチ時のエラー
}

struct ErrorMessage
{
    static let faildToReadCuona = "Failed to read CUONA tag"                // CUONA読み込みに失敗
    static let notExistEventToken = "Favor's event action does not exist"    // イベントアクションが存在しない
    static let invalidEventToken = "Favor's event token is invalid"         // イベントトークンが正しくない
}

struct ApiUrl
{
    static let endPoint = "http://favor-dev.cuona.io"   // エンドポイント（開発サーバー）
//    static let endPoint = "http://favor-test.cuona.io"   // エンドポイント（テストサーバー）
    
    static let registerUesr = endPoint + "/api/users/register.json"                  // ユーザー登録
    static let getUser = endPoint + "/api/users/setting.json"                        // ユーザー情報取得
    static let editUser = endPoint + "/api/users/setting.json"                       // ユーザー情報編集
    static let enterShop = endPoint + "/api/users/enter.json"                        // 入店
    static let getVisitedShopHistory = endPoint + "/api/users/visit_histories.json"  // 入店履歴一覧取得
    static let getUsersAllOrder = endPoint + "/api/users/orders.json"                // 注文履歴一覧(ユーザーの全店舗での注文履歴)
    static let addFavorite = endPoint + "/api/users/favorites.json"                  // お気に入り登録
    static let getFavoriteList = endPoint + "/api/users/favorites.json"              // お気に入り一覧取得
    
    // 店舗詳細取得
    static func getShopDetail(_ shopId: Int) -> String {
        return endPoint + "/api/users/shops/\(shopId).json"
    }
    
    // 店舗メニュー取得
    static func getMenu(_ shopId: Int) -> String {
        return endPoint + "/api/users/shops/\(shopId)/menu.json"
    }
    
    // 注文
    static func order(_ visitHistoryId: Int) -> String {
        return endPoint + "/api/users/visit_histories/\(visitHistoryId)/orders.json"
    }
    
    // 注文履歴一覧(来店個人単位)
    static func getUsersOrderInShop(_ visitHistoryId: Int) -> String {
        return endPoint + "/api/users/visit_histories/\(visitHistoryId)/orders"
    }
    
    // 注文履歴一覧(来店グループ単位)
    static func getUserGroupsOrderInShop(_ visitGroupId: Int) -> String {
        return endPoint + "/api/users/visit_groups/\(visitGroupId)/orders"
    }
    
    // お会計
    static func check(_ visitHistoryId: Int) -> String {
        return endPoint + "/api/users/visit_histories/\(visitHistoryId)/order_stop.json"
    }
    
    // お気に入り編集
    static func editFavorite(_ favoriteId: Int) -> String {
        return endPoint + "/api/users/favorites/\(favoriteId).json"
    }
    
    // お気に入り削除
    static func deleteFavorite(_ favoriteId: Int) -> String {
        return endPoint + "/api/users/favorites/\(favoriteId).json"
    }
}
