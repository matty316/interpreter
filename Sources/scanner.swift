//
//  scanner.swift
//  interpreter
//
//  Created by Matthew Reed on 11/13/24.
//

import Foundation

enum ScannerError: Error {
    case invalidCharacter
    case unterminatedString
}

class Scanner {
    let source: String
    var start: String.Index
    var position: String.Index
    var line: Int = 1
    var tokens: [Token] = []
    var isAtEnd: Bool { position == source.endIndex }
    var peek: Character {
        guard !isAtEnd else { return "\0" }
        return source[position]
    }
    let keywords: [String: Token.TokenType] = [
        "let": .Let,
        "if": .If,
        "else": .Else,
        "while": .While,
        "true": .True,
        "false": .False,
        "class": .Class,
        "fun": .Fun,
        "return": .Return,
        "for": .For,
        "null": .Null
    ]
    
    init(source: String) {
        self.source = source
        start = source.startIndex
        position = source.startIndex
    }
    
    func scan() throws {
        while !isAtEnd {
            try scanToken()
        }
        addToken(type: .Eof)
    }
    
    func scanToken() throws {
        start = position
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
                while peek != "\n" && !isAtEnd {
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
        case "\"": try string()
        case " ", "\r", "\t": break
        case "\n":
            line += 1
            addToken(type: .Newline)
        default:
            if isAlpha(c) {
                identifier()
            } else if isDigit(c) {
                number()
            } else {
                throw ScannerError.invalidCharacter
            }
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
    
    func isAlpha(_ c: Character) -> Bool {
        return c.isLetter || c == "_"
    }
    
    func isDigit(_ c: Character) -> Bool {
        return c.isNumber
    }
    
    func isAlphaNumeric(_ c: Character) -> Bool {
        return isAlpha(c) || isDigit(c)
    }
    
    func identifier() {
        while isAlphaNumeric(peek) && !isAtEnd {
            advance()
        }
        
        let identifier = String(source[start..<position])
        if let tokenType = keywords[identifier] {
            let token = Token(type: tokenType, lexeme: identifier, line: line)
            tokens.append(token)
        } else {
            let token = Token(type: .Identifier, lexeme: identifier, line: line)
            tokens.append(token)
        }
    }
    
    func number() {
        while isDigit(peek) && !isAtEnd {
            advance()
        }
        if peek == "." {
            advance()
            while isDigit(peek) && !isAtEnd {
                advance()
            }
        }
        
        let number = String(source[start..<position])
        if number.contains(".") {
            let token = Token(type: .Float, lexeme: number, line: line)
            tokens.append(token)
        } else {
            let token = Token(type: .Integer, lexeme: number, line: line)
            tokens.append(token)
        }
    }
    
    func string() throws {
        while peek != "\"" && !isAtEnd {
            if peek == "\n" {
                line += 1
            }
            advance()
        }
        
        if isAtEnd {
            throw ScannerError.unterminatedString
        }
        advance()
        
        let string = String(source[source.index(after: start)..<source.index(before: position)])
        let token = Token(type: .String, lexeme: string, line: line)
        tokens.append(token)
    }
}
