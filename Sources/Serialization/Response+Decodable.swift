//
//  Response+Decodable.swift
//  
//
//  Created by linshizai on 2022/6/10.
//

import Foundation
import Moya

/// Extension for processing Responses into frequently used objects
public extension Response {
    func mapVoid() throws {
        try extract()
    }

    func mapStringArray() throws -> [String] {
        let jsonObject: Any? = try extract()
        if let object = jsonObject as? [String] {
            return object
        }
        throw MoyaError.jsonMapping(self)
    }

    func mapDictionary() throws -> [String: String] {
        let jsonObject: Any? = try extract()
        if let object = jsonObject as? [String: String] {
            return object
        }
        return [:]
    }
    
    func mapCustomString(atKeyPath keyPath: String? = nil) throws -> String {
        let jsonObject: Any? = try extract(atKeyPath: keyPath)
        if let keyPath = keyPath {
            if let string = ((jsonObject as? NSDictionary)?.value(forKeyPath: keyPath)) as? String {
                return string
            }
            throw MoyaError.jsonMapping(self)
        } else {
            if let string = jsonObject as? String {
                return string
            }
            throw MoyaError.jsonMapping(self)
        }
    }
}

public extension Response {
    
    func mapObject<T: Decodable>(_ type: T.Type, atKeyPath keyPath: String? = nil, extractor: Extrator = Extrator.default) throws -> T {
        do {
            let json = try extract(atKeyPath: keyPath, extractor: extractor)
            let data = try JSONSerialization.data(withJSONObject: json)
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            throw MoyaError.jsonMapping(self)
        }
    }
    
    @discardableResult
    private func extract(atKeyPath keyPath: String? = nil, extractor: Extrator = .default) throws -> Any {
        
        if statusCode >= 500 {
            throw ReponseErrorType.serverSide
        }
        
        if let _ = extractor.context  {
            // Can do anything ....
        }
        
        if let jsonObject = try extractor.extracting?(data) {
            return jsonObject
        } else {
            return try extractRaw(atKeyPath: keyPath)
        }
    }
    
    func extractRaw(atKeyPath keyPath: String? = nil) throws -> Any {
        var json = try mapJSON()
        if let keyPath = keyPath,
           let dictionary = json as? NSDictionary,
           let value = dictionary.value(forKeyPath: keyPath) {
            json = value
        }
        return json
    }
}
