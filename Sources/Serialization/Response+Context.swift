//
//  Response+Context.swift
//  
//
//  Created by linshizai on 2022/6/12.
//

import Foundation


/// SerializeContext is available for developers who wish to pass information around during the decoding process.
public protocol SerializeContext {}

public struct Extrator {
    public let context: SerializeContext?
    public let extracting: ((Data)throws -> Any?)?
    
    public init(context: SerializeContext? = nil, extracting: ((Data)->Any)? = nil) {
        self.context = context
        self.extracting = extracting
    }
    
    public static let `default` = Extrator()
}

public enum ReponseErrorType: Error, LocalizedError {
    case serverSide
    case customn(Error)
}
