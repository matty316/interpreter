//
//  token.swift
//  interpreter
//
//  Created by Matthew Reed on 11/13/24.
//

struct Token {
    let type: TokenType
    let lexeme: String
    let line: Int
    
    enum TokenType: String {
        case LeftParen = "("
        case RightParen = ")"
        case LeftBrace = "{"
        case RightBrace = "}"
        case GreaterThan = ">"
        case GreaterThanEqual = ">="
        case LessThan = "<"
        case LessThanEqual = "<="
        case Equal = "="
        case EqualEqual = "=="
        case Plus = "+"
        case Minus = "-"
        case Slash = "/"
        case SlashSlash = "//"
        case Semicolon = ";"
        case Dot = "."
        case Star = "*"
        case Colon = ":"
        case Comma = ","
        case Bang = "!"
        case BangEqual = "!="
        case Number
        case Identifier
        case Eof
    }
}
