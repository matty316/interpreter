//
//  env.swift
//  interpreter
//
//  Created by Matthew Reed on 11/21/24.
//

enum EnvError: Error {
    case UndefinedVariable(String)
}

class Env {
    var enclosing: Env? = nil
    
    init() {}
    
    init(enclosing: Env) {
        self.enclosing = enclosing
    }
    
    var values = [String: Any]()
    
    func define(name: String, value: Any?) {
        values[name] = value
    }
    
    func get(name: String) throws -> Any {
        guard let value = values[name] else {
            if let enclosing = enclosing {
                return try enclosing.get(name: name)
            }
            
            throw EnvError.UndefinedVariable(name)
        }
        
        return value
    }
    
    func assign(name: String, value: Any?) throws {
        guard values[name] != nil else {
            if let enclosing = enclosing {
                try enclosing.assign(name: name, value: value)
                return
            }
            
            throw EnvError.UndefinedVariable(name)
        }
        
        values[name] = value
    }
}
