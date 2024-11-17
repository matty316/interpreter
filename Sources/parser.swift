//
//  parser.swift
//  interpreter
//
//  Created by Matthew Reed on 11/15/24.
//

enum ParserError: Error {
    case invalidToken(Token)
}

class Parser {
    let tokens: [Token]
    var position = 0
    var peek: Token { tokens[position] }
    var prev: Token { tokens[position - 1] }
    var isAtEnd: Bool { peek.type == .Eof }
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse() throws -> Program {
        var stmts = [Stmt]()
        
        while !isAtEnd {
            if let stmt = try parseStmt() {
                stmts.append(stmt)
            }
        }
        
        return Program(stmts: stmts)
    }
    
    func parseStmt() throws -> Stmt? {
        if match(types: [.Eof, .Newline, .Semicolon]) { return nil }
        return try expressionStmt()
    }
    
    func expressionStmt() throws -> Stmt {
        let expr = try expression()
        return Expression(expr: expr)
    }
    
    func expression() throws -> Expr {
        let expr = try comparison()
        return expr
    }
    
    func comparison() throws -> Expr {
        var left = try term()
        
        while match(types: [.LessThan, .LessThanEqual, .GreaterThan, .GreaterThanEqual]) {
            let op = prev
            let right = try term()
            left = Binary(left: left, right: right, op: op)
        }
        
        return left
    }
    
    func term() throws -> Expr {
        var left = try factor()
        
        while match(types: [.Plus, .Minus]) {
            let op = prev
            let right = try factor()
            left = Binary(left: left, right: right, op: op)
        }
        
        return left
    }
    
    func factor() throws -> Expr {
        var left = try unary()
        
        while match(types: [.Star, .Slash]) {
            let op = prev
            let right = try unary()
            left = Binary(left: left, right: right, op: op)
        }
        
        return left
    }

    func unary() throws -> Expr {
        if match(types: [.Bang, .Minus]) {
            let op = prev
            let right = try unary()
            return Unary(op: op, right: right)
        }
        
        return try primary()
    }
    
    func primary() throws -> Expr {
        if match(types: [.True]) {
            return Boolean(value: true)
        }
        if match(types: [.False]) {
            return Boolean(value: false)
        }
        if match(types: [.Null]) {
            return Null()
        }
        if match(types: [.String]) {
            return StringVal(value: prev.lexeme)
        }
        if match(types: [.Float]) {
            let token = prev
            guard let value = Double(token.lexeme) else {
                throw ParserError.invalidToken(prev)
            }
            return Float(value: value)
        }
        if match(types: [.Integer]) {
            let token = prev
            guard let value = Int(token.lexeme) else {
                throw ParserError.invalidToken(prev)
            }
            return Integer(value: Int(value))
        }
        
        if match(types: [.LeftParen]) {
            let expr = try expression()
            try consume(tokenType: .RightParen)
            return expr
        }
        return try expression()
    }
    
    @discardableResult
    func advance() -> Token {
        if !isAtEnd { position += 1 }
        return prev
    }
    
    func match(types: [Token.TokenType]) -> Bool {
        for tokenType in types {
            if check(tokenType: tokenType) {
                advance()
                return true
            }
        }
        return false
    }
    
    func check(tokenType: Token.TokenType) -> Bool {
        if isAtEnd { return false }
        return peek.type == tokenType
    }
    
    @discardableResult
    func consume(tokenType: Token.TokenType) throws -> Token {
        guard check(tokenType: tokenType) else {
            throw ParserError.invalidToken(peek)
        }
        return advance()
    }
}
