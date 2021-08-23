//
//  File.swift
//  
//
//  Created by ashokdy on 23/08/2021.
//

import Foundation

public protocol APIPath {
    var subURL: String { get }
    var httpMethod: HTTPMethod { get }
    var params: [String: Any] { get }
}

public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
    case put = "PUT"
}
