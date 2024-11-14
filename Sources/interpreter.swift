//
//  interpreter.swift
//  interpreter
//
//  Created by Matthew Reed on 11/13/24.
//

import Foundation
import ArgumentParser

@main
struct Interpreter: ParsableCommand {
    @Argument var path: String?
    
    func run() throws {
        if let path = path {
            let url = URL(filePath: path)
            let source = try String(contentsOf: url, encoding: .utf8)
            let scanner = Scanner(source: source)
            try scanner.scan()
            print(scanner.tokens)
        } else {
            try repl()
        }
    }
    
    func repl() throws {
        while true {
            print("REPL > ", terminator: "")
            let input = readLine(strippingNewline: true)!
            let scanner = Scanner(source: input)
            try scanner.scan()
            print(scanner.tokens)
        }
    }
}
