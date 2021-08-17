//
//  File.swift
//  
//
//  Created by ashokdy on 17/08/2021.
//

import Foundation

public struct APIResponse {
    
    let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public func getModel<T:Codable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self.data)
    }
}
