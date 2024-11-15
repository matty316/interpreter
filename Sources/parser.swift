//
//  parser.swift
//  interpreter
//
//  Created by Matthew Reed on 11/15/24.
//

enum ParserError: Error {
    case invalidToken
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
        let left = try term()
        
        while match(types: [.LessThan, .LessThanEqual, .GreaterThan, .GreaterThanEqual]) {
            let op = prev
            let right = try term()
            return Binary(left: left, right: right, op: op)
        }
        
        return left
    }
    
    func term() throws -> Expr {
        let left = try unary()
        
        while match(types: [.Plus, .Minus]) {
            let op = prev
            let right = try unary()
            return Binary(left: left, right: right, op: op)
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
        if match(types: [.Integer]) {
            let token = prev
            guard let value = Int(token.lexeme) else {
                throw ParserError.invalidToken
            }
            return Integer(value: Int(value))
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
        if check(tokenType: tokenType) { advance() }
        throw ParserError.invalidToken
    }
}
