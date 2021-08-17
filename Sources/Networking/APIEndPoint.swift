//
//  File.swift
//  
//
//  Created by ashokdy on 17/08/2021.
//

import Foundation

//MARK: API constants
public struct API {
    static let baseUrl = ""
    static let subUrl = ""
    
    struct Headers {
        static let authorization = "Authorization"
        static let accept = "Accept"
    }
}

//MARK: Headers
public enum HttpMethod :String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

//MARK: Endpoint Protocol with vairables
public protocol APIEndpoint {
    var baseUrl: String { get }
    var subUrl: String { get }
    var url : String { get }
}

//MARK: APIEndpoint default extension
public extension APIEndpoint {
    
    var baseUrl: String {
        return API.baseUrl
    }
    
    var subUrl: String {
        return API.subUrl
    }
    
    var httpMethod: HttpMethod {
        return .get
    }
    
    var url : String {
        return baseUrl + subUrl
    }
}
