//
//  InterpreterTests.swift
//  interpreter
//
//  Created by Matthew Reed on 11/13/24.
//

import Testing
@testable import interpreter

struct InterpreterTests {

    @Test func scanSingleToken() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let source = "( ) ! < > = { } + - * / ; , : ."
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 17)
        #expect(scanner.tokens[0].type == .LeftParen)
        #expect(scanner.tokens[1].type == .RightParen)
        #expect(scanner.tokens[2].type == .Bang)
        #expect(scanner.tokens[3].type == .LessThan)
        #expect(scanner.tokens[4].type == .GreaterThan)
        #expect(scanner.tokens[5].type == .Equal)
        #expect(scanner.tokens[6].type == .LeftBrace)
        #expect(scanner.tokens[7].type == .RightBrace)
        #expect(scanner.tokens[8].type == .Plus)
        #expect(scanner.tokens[9].type == .Minus)
        #expect(scanner.tokens[10].type == .Star)
        #expect(scanner.tokens[11].type == .Slash)
        #expect(scanner.tokens[12].type == .Semicolon)
        #expect(scanner.tokens[13].type == .Comma)
        #expect(scanner.tokens[14].type == .Colon)
        #expect(scanner.tokens[15].type == .Dot)
        #expect(scanner.tokens[16].type == .Eof)
    }

    @Test func scanMultiToken() async throws {
        let source = """
== <= >= // this is a comment
!= = = < = > = / /
"""
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 15)
        #expect(scanner.tokens[0].type == .EqualEqual)
        #expect(scanner.tokens[1].type == .LessThanEqual)
        #expect(scanner.tokens[2].type == .GreaterThanEqual)
        #expect(scanner.tokens[3].type == .SlashSlash)
        #expect(scanner.tokens[4].type == .Newline)
        #expect(scanner.tokens[5].type == .BangEqual)
        #expect(scanner.tokens[6].type == .Equal)
        #expect(scanner.tokens[7].type == .Equal)
        #expect(scanner.tokens[8].type == .LessThan)
        #expect(scanner.tokens[9].type == .Equal)
        #expect(scanner.tokens[10].type == .GreaterThan)
        #expect(scanner.tokens[11].type == .Equal)
        #expect(scanner.tokens[12].type == .Slash)
        #expect(scanner.tokens[13].type == .Slash)
        #expect(scanner.tokens[14].type == .Eof)
    }
    
    @Test func scanIdentifier() async throws {
        let source = "let foo bar"
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 4)
        #expect(scanner.tokens[0].lexeme == "let")
        #expect(scanner.tokens[0].type == .Let)
        #expect(scanner.tokens[1].lexeme == "foo")
        #expect(scanner.tokens[1].type == .Identifier)
        #expect(scanner.tokens[2].lexeme == "bar")
        #expect(scanner.tokens[2].type == .Identifier)
        #expect(scanner.tokens[3].type == .Eof)
    }
    
    @Test func scanNumber() async throws {
        let source = "12 243 456 1.1 2.5 2"
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 7)
        #expect(scanner.tokens[0].lexeme == "12")
        #expect(scanner.tokens[0].type == .Integer)
        #expect(scanner.tokens[1].lexeme == "243")
        #expect(scanner.tokens[1].type == .Integer)
        #expect(scanner.tokens[2].lexeme == "456")
        #expect(scanner.tokens[2].type == .Integer)
        #expect(scanner.tokens[3].lexeme == "1.1")
        #expect(scanner.tokens[3].type == .Float)
        #expect(scanner.tokens[4].lexeme == "2.5")
        #expect(scanner.tokens[4].type == .Float)
        #expect(scanner.tokens[5].lexeme == "2")
        #expect(scanner.tokens[5].type == .Integer)
        #expect(scanner.tokens[6].type == .Eof)
    }
    
    @Test func scanString() async throws {
        let source = "let var = \"Hello, world!\""
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 5)
        #expect(scanner.tokens[3].lexeme == "Hello, world!")
        #expect(scanner.tokens[3].type == .String)
    }
    
    @Test func scanKeywords() async throws {
        let source = "let if else fun class return for while true false"
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 11)
        let tokens: [Token.TokenType] = [.Let, .If, .Else, .Fun, .Class, .Return, .For, .While, .True, .False, .Eof]
        
        for (i, tokenType) in tokens.enumerated() {
            let t = scanner.tokens[i]
            #expect(t.type == tokenType)
        }
    }
    
    @Test func parseUnary() async throws {
        let source = "-1"
        let scanner = Scanner(source: source)
        try scanner.scan()
        let parser = Parser(tokens: scanner.tokens)
        let program = try parser.parse()
        #expect(program.stmts.count == 1)
        guard let stmt = program.stmts.first as? Expression, let expr = stmt.expr as? Unary else {
            #expect(Bool(false))
            return
        }
        
        #expect(expr.op.type == .Minus)
        guard let right = expr.right as? Integer else {
            #expect(Bool(false))
            return
        }
        #expect(right.value == 1)
    }
    
    @Test func parseBinary() async throws {
        let source = """
1 + 2
10 >= 3; 5 + 7

"""
        
        let scanner = Scanner(source: source)
        try scanner.scan()
        let parser = Parser(tokens: scanner.tokens)
        let program = try parser.parse()
        
        let expectedExpr: [Binary] = [
            Binary(left: Integer(value: 1), right: Integer(value: 2), op: Token(type: .Plus, lexeme: "+", line: 1)),
            Binary(left: Integer(value: 10), right: Integer(value: 3), op: Token(type: .GreaterThanEqual, lexeme: ">=", line: 2)),
            Binary(left: Integer(value: 5), right: Integer(value: 7), op: Token(type: .Plus, lexeme: "+", line: 2)),
        ]
        
        #expect(program.stmts.count == 3)
        for (i, expr) in expectedExpr.enumerated() {
            let testStmt = program.stmts[i]
            guard let testStmt = testStmt as? Expression, let testExpr = testStmt.expr as? Binary else {
                #expect(Bool(false))
                return
            }
            
            #expect(testExpr.op.type == expr.op.type)
            guard let left = testExpr.left as? Integer, let right = testExpr.right as? Integer else {
                #expect(Bool(false))
                return
            }
            
            let expectedLeft = expr.left as! Integer
            let expectedRight = expr.right as! Integer
            
            #expect(left.value == expectedLeft.value)
            #expect(right.value == expectedRight.value)
        }
        guard let stmt = program.stmts.first as? Expression, let expr = stmt.expr as? Binary else {
            #expect(Bool(false))
            return
        }
        #expect(expr.op.type == .Plus)
        guard let left = expr.left as? Integer, let right = expr.right as? Integer else {
            #expect(Bool(false))
            return
        }
        
        #expect(left.value == 1)
        #expect(right.value == 2)
    }
}
