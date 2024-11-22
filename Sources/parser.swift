//
//  parser.swift
//  interpreter
//
//  Created by Matthew Reed on 11/15/24.
//

enum ParserError: Error {
    case invalidToken(Token)
    case invalidAssignment(Token)
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
            if let stmt = try declaration() {
                stmts.append(stmt)
            }
        }
        
        return Program(stmts: stmts)
    }
    
    func declaration() throws -> Stmt? {
        if match(types: [.Let]) { return try varDeclaration() }
        if match(types: [.Newline, .Eof, .Semicolon]) { return nil }
        return try stmt()
    }
    
    func varDeclaration() throws -> Stmt? {
        let name = try consume(tokenType: .Identifier)
        var initializer: Expr? = nil
        
        if match(types: [.Equal]) {
            initializer = try expression()
        }
        
        return VarStmt(name: name.lexeme, initializer: initializer)
    }
    
    func stmt() throws -> Stmt? {
        if match(types: [.LeftBrace]) { return try parseBlock() }
        return try expressionStmt()
    }
    
    func parseBlock() throws -> Stmt? {
        var stmts = [Stmt]()
        
        while !check(tokenType: .RightBrace) && !isAtEnd {
            if let stmt = try declaration() {
                stmts.append(stmt)
            }
        }
        
        try consume(tokenType: .RightBrace)
        return Block(stmts: stmts)
    }
    
    func expressionStmt() throws -> Stmt {
        let expr = try expression()
        return Expression(expr: expr)
    }
    
    func expression() throws -> Expr {
        return try assignment()
    }
    
    func assignment() throws -> Expr {
        let expr = try comparison()
        
        if match(types: [.Equal]) {
            let equals = prev
            let value = try assignment()
            
            if let expr = expr as? Var {
                let name = expr.name
                return Assign(name: name, value: value)
            }
            
            throw ParserError.invalidAssignment(equals)
        }
        
        return expr
    }
    
    func comparison() throws -> Expr {
        var left = try term()
        
        while match(types: [.LessThan, .LessThanEqual, .GreaterThan, .GreaterThanEqual, .EqualEqual, .BangEqual]) {
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
            return FloatVal(value: value)
        }
        if match(types: [.Integer]) {
            let token = prev
            guard let value = Int(token.lexeme) else {
                throw ParserError.invalidToken(prev)
            }
            return Integer(value: Int(value))
        }
        
        if match(types: [.Identifier]) {
            return Var(name: prev.lexeme)
        }
        
        if match(types: [.LeftParen]) {
            let expr = try expression()
            try consume(tokenType: .RightParen)
            return expr
        }
        throw ParserError.invalidToken(peek)
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
