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
    var headers: [String: String] { get }
    var queryURL: String { get }
    var data: Data? { get }
}

extension APIPath {
    public var httpMethod: HTTPMethod { .get }
    public var params: [String: Any] { [:] }
    public var headers: [String: String] { [:] }
    public var queryURL: String { "" }
    public var data: Data? { nil }
}

public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
    case put = "PUT"
}
