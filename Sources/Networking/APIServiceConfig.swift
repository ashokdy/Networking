//
//  File.swift
//  
//
//  Created by ashokdy on 23/08/2021.
//

import Foundation

public struct APIServiceConfig {
    public static let shared = APIServiceConfig()
    var baseURL = ""
    
    public mutating func setup(baseURL: String) {
        self.baseURL = baseURL
    }
}

public enum APIService {
    static let apiClient = APIClient()
    static let baseURL = URL(string: APIServiceConfig.shared.baseURL)!
}
