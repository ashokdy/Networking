//
//  File.swift
//  
//
//  Created by ashokdy on 23/08/2021.
//

import Foundation
import Combine

public class APIServiceConfig {
    public static let shared = APIServiceConfig()
    public var baseURL = ""
    
    public func setup(baseURL: String) {
        self.baseURL = baseURL
    }
}

public enum APIService {
    public static let apiClient = APIClient()
    public static let baseURL = URL(string: APIServiceConfig.shared.baseURL)!
}
