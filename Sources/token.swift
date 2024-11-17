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
        case Integer
        case Float
        case String
        case Identifier
        case Let
        case If
        case Else
        case For
        case While
        case Fun
        case Return
        case Class
        case True
        case False
        case Null
        case Newline
        case Eof
    }
}
