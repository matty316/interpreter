//
//  parser.swift
//  interpreter
//
//  Created by Matthew Reed on 11/15/24.
//

enum ParserError: Error {
    case invalidToken(Token)
    case invalidAssignment(Token)
    case ifWithNoThenBranch
    case noPrefixParseFn(Token)
    case noInfixParseFn(Token)
    case forWithNoInit
}

typealias PrefixParseFn = () throws -> Expr
typealias InfixParseFn = (Expr) throws -> Expr

enum Precedence: Int {
    case lowest = 0
    case equals = 1
    case lessGreater = 2
    case sum = 3
    case product = 4
    case prefix = 5
    case call = 6
    case index = 7
}

extension TokenType {
    var precedence: Precedence {
        switch self {
        case .EqualEqual, .BangEqual: return .equals
        case .LessThan, .GreaterThan, .LessThanEqual, .GreaterThanEqual: return .lessGreater
        case .Plus, .Minus: return .sum
        case .Star, .Slash: return .product
        case .LeftParen: return .call
        default: return .lowest
        }
    }
}

class Parser {
    let tokens: [Token]
    var position = 0
    var peek: Token { tokens[position] }
    var prev: Token { tokens[position - 1] }
    var isAtEnd: Bool { peek.tokenType == .Eof }
    
    var prefixParseFns = [TokenType: PrefixParseFn]()
    var infixParseFns = [TokenType: InfixParseFn]()
    
    init(tokens: [Token]) {
        self.tokens = tokens
        
        self.prefixParseFns[.Identifier] = parseIdent
        self.prefixParseFns[.Integer] = parseInt
        self.prefixParseFns[.Float] = parseFloat
        self.prefixParseFns[.String] = parseString
        self.prefixParseFns[.True] = parseBoolean
        self.prefixParseFns[.False] = parseBoolean
        self.prefixParseFns[.Minus] = parsePrefix
        self.prefixParseFns[.Bang] = parsePrefix
        self.prefixParseFns[.LeftParen] = parseGrouping
        self.prefixParseFns[.If] = parseIf
        
        self.infixParseFns[.Plus] = parseInfix
        self.infixParseFns[.Minus] = parseInfix
        self.infixParseFns[.Star] = parseInfix
        self.infixParseFns[.Slash] = parseInfix
        self.infixParseFns[.LessThan] = parseInfix
        self.infixParseFns[.LessThanEqual] = parseInfix
        self.infixParseFns[.GreaterThan] = parseInfix
        self.infixParseFns[.GreaterThanEqual] = parseInfix
        self.infixParseFns[.BangEqual] = parseInfix
        self.infixParseFns[.EqualEqual] = parseInfix
        self.infixParseFns[.Equal] = parseAssign
        self.infixParseFns[.And] = parseInfix
        self.infixParseFns[.Or] = parseInfix
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
        if match(types: [.Let]) { return try parseLet() }
        if match(types: [.LeftBrace]) { return try parseBlock() }
        if match(types: [.While]) { return try parseWhile() }
        if match(types: [.For]) { return try parseFor() }
        if match(types: [.Newline, .Semicolon]) { return nil }
        return try parseExpressionStmt()
    }
    
    func parseLet() throws -> Stmt? {
        let name = try consume(tokenType: .Identifier)
        var initializer: Expr? = nil
        
        if match(types: [.Equal]) {
            initializer = try parseExpr(.lowest)
        }
        
        return LetStmt(name: name.lexeme, initializer: initializer)
    }
    
    func parseWhile() throws -> While {
        let condition = try parseExpr(.lowest)
        try consume(tokenType: .LeftBrace)
        let body = try parseBlock()
        return While(condition: condition, body: body)
    }
    
    func parseFor() throws -> For {
        guard let initializer = try parseStmt() else {
            throw ParserError.forWithNoInit
        }
        try consume(tokenType: .Semicolon)
        let condition = try parseExpr(.lowest)
        try consume(tokenType: .Semicolon)
        let increment = try parseExpr(.lowest)
        try consume(tokenType: .LeftBrace)
        let body = try parseBlock()
        return For(initializer: initializer, condition: condition, increment: increment, body: body)
    }
    
    func parseBlock() throws -> Block {
        var stmts = [Stmt]()
        
        while !check(tokenType: .RightBrace) && !isAtEnd {
            if let stmt = try parseStmt() {
                stmts.append(stmt)
            }
        }
        
        try consume(tokenType: .RightBrace)
        return Block(stmts: stmts)
    }
    
    func parseExpressionStmt() throws -> Stmt {
        let expr = try parseExpr(.lowest)
        if check(tokenType: .Newline) || check(tokenType: .Semicolon) {
            advance()
        }
        return ExpressionStmt(expr: expr)
    }
    
    func parseExpr(_ precedence: Precedence) throws -> Expr {
        guard let prefix = prefixParseFns[peek.tokenType] else {
            throw ParserError.noPrefixParseFn(peek)
        }
        
        var left = try prefix()
        advance()
        
        while !check(tokenType: .Newline) || !check(tokenType: .Semicolon) || !check(tokenType: .Eof) && precedence.rawValue < peek.tokenType.precedence.rawValue {
            guard let infix = infixParseFns[peek.tokenType] else {
                return left
            }
            
            advance()
            left = try infix(left)
        }
        
        return left
    }
    
    func parseIdent() -> Expr {
        return Identifier(name: peek.lexeme)
    }
    
    func parseInt() throws -> Expr {
        guard let num = Int(peek.lexeme) else {
            throw ParserError.invalidToken(peek)
        }
        return Integer(value: num)
    }
    
    func parseFloat() throws -> Expr {
        guard let num = Double(peek.lexeme) else {
            throw ParserError.invalidToken(peek)
        }
        return FloatVal(value: num)
    }
    
    func parseBoolean() throws -> Expr {
        return Boolean(value: peek.tokenType == .True)
    }
    
    func parseString() throws -> Expr {
        return StringVal(value: peek.lexeme)
    }
    
    func parsePrefix() throws -> Expr {
        let op = peek
        advance()
        
        let right = try parseExpr(.lowest) 
        
        return Unary(op: op, right: right)
    }
    
    func parseInfix(expr: Expr) throws -> Expr {
        let op = prev
        let prec = peek.tokenType.precedence
        let right = try parseExpr(prec)
        return Binary(left: expr, right: right, op: op)
    }
    
    func parseGrouping() throws -> Expr {
        advance()
        let expr = try parseExpr(.lowest)
        return expr
    }
    
    func parseIf() throws -> Expr {
        advance()
        let condition = try parseExpr(.lowest)
        try consume(tokenType: .LeftBrace)
        let thenBranch = try parseBlock()
        var elseBranch: Block? = nil
        if match(types: [.Else]) {
            try consume(tokenType: .LeftBrace)
            elseBranch = try parseBlock()
        }
        return IfExpr(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
    }
    
    func parseAssign(expr: Expr) throws -> Expr {
        guard let ident = expr as? Identifier else {
            throw ParserError.invalidToken(peek)
        }
        let name = ident.name
        let val = try parseExpr(.lowest)
        return Assign(name: name, value: val)
    }
    
    @discardableResult
    func advance() -> Token {
        if !isAtEnd { position += 1 }
        return prev
    }
    
    func match(types: [TokenType]) -> Bool {
        for tokenType in types {
            if check(tokenType: tokenType) {
                advance()
                return true
            }
        }
        return false
    }
    
    func check(tokenType: TokenType) -> Bool {
        return peek.tokenType == tokenType
    }
    
    @discardableResult
    func consume(tokenType: TokenType) throws -> Token {
        guard check(tokenType: tokenType) else {
            throw ParserError.invalidToken(peek)
        }
        return advance()
    }
}
