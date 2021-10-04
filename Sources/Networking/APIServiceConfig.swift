//
//  File.swift
//  
//
//  Created by ashokdy on 25/08/2021.
//

import Foundation

public struct APIData {
    public var baseURL: String
    public var accessToken: String = ""
    public var basicToken: String
    public init(baseURL: String, basicToken: String = "") {
        self.baseURL = baseURL
        self.basicToken = basicToken
    }
}

public class APIServiceConfig {
    public static let shared = APIServiceConfig()
    public var apiData: APIData
    
    public func setup(apiData: APIData) {
        self.apiData = apiData
    }
    
    init() {
        self.apiData = APIData(baseURL: "", basicToken: "")
    }
    
    public func update(accessToken: String) {
        self.apiData.accessToken = accessToken
    }
}
