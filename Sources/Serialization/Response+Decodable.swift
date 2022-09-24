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
    
    func mapVoid(extractor: Extrator = Extrator.default) throws {
        try extract(extractor: extractor)
    }

    func mapStringArray(extractor: Extrator = Extrator.default) throws -> [String] {
        let jsonObject: Any? = try extract(extractor: extractor)
        if let object = jsonObject as? [String] {
            return object
        }
        throw MoyaError.jsonMapping(self)
    }

    func mapDictionary(extractor: Extrator = Extrator.default) throws -> [String: String] {
        let jsonObject: Any? = try extract(extractor: extractor)
        if let object = jsonObject as? [String: String] {
            return object
        }
        return [:]
    }
    
    func mapCustomString(atKeyPath keyPath: String? = nil, extractor: Extrator = Extrator.default) throws -> String {
        let jsonObject: Any? = try extract(atKeyPath: keyPath, extractor: extractor)
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
    
    func mapObject<T: Decodable>(_ type: T.Type, atKeyPath keyPath: String? = nil, extractor: Extrator = Extrator.default) throws -> T {
        do {
            let json = try extract(atKeyPath: keyPath, extractor: extractor)
            let data = try JSONSerialization.data(withJSONObject: json)
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            throw MoyaError.objectMapping(error, self)
        }
    }
}

public extension Response {
    
     
    // Extract response data by extractor's customn extracting block
    @discardableResult
    private func extract(atKeyPath keyPath: String? = nil, extractor: Extrator = .default) throws -> Any {
        
        if statusCode >= 500 {
            throw MoyaError.statusCode(self)
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
    
    // Extract response data directly, no extractor
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
