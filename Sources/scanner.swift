//
//  scanner.swift
//  interpreter
//
//  Created by Matthew Reed on 11/13/24.
//

import Foundation

enum ScannerError: Error {
    case invalidCharacter
}

class Scanner {
    let source: String
    var position: String.Index
    var line: Int = 1
    var tokens: [Token] = []
    var isAtEnd: Bool { position == source.endIndex }
    var peek: Character {
        guard !isAtEnd else { return "\0" }
        return source[position]
    }
    
    init(source: String) {
        self.source = source
        position = source.startIndex
    }
    
    func scan() throws {
        while !isAtEnd {
            try scanToken()
        }
        addToken(type: .Eof)
    }
    
    func scanToken() throws {
        let c = advance()
        
        switch c {
        case "(": addToken(type: .LeftParen)
        case ")": addToken(type: .RightParen)
        case "+": addToken(type: .Plus)
        case "-": addToken(type: .Minus)
        case "*": addToken(type: .Star)
        case "/":
            if peek == "/" {
                addToken(type: .SlashSlash)
                while peek != "\n" {
                    advance()
                }
            } else {
                addToken(type: .Slash)
            }
        case "=":
            if peek == "=" {
                addToken(type: .EqualEqual)
                advance()
            } else {
                addToken(type: .Equal)
            }
        case "{": addToken(type: .LeftBrace)
        case "}": addToken(type: .RightBrace)
        case ":": addToken(type: .Colon)
        case ";": addToken(type: .Semicolon)
        case ",": addToken(type: .Comma)
        case ".": addToken(type: .Dot)
        case "<":
            if peek == "=" {
                addToken(type: .LessThanEqual)
                advance()
            } else {
                addToken(type: .LessThan)
            }
        case ">": 
            if peek == "=" {
                addToken(type: .GreaterThanEqual)
                advance()
            } else {
                addToken(type: .GreaterThan)
            }
        case "!":
            if peek == "=" {
                addToken(type: .BangEqual)
                advance()
            } else {
                addToken(type: .Bang)
            }
        case " ", "\r", "\t": break
        case "\n": line += 1
        default: throw ScannerError.invalidCharacter
        }
    }
    
    @discardableResult
    func advance() -> Character {
        guard !isAtEnd else { return "\0" }
        let char = source[position]
        position = source.index(after: position)
        return char
    }
    
    func addToken(type: Token.TokenType) {
        let token = Token(type: type, lexeme: type.rawValue, line: line)
        tokens.append(token)
    }
}
