//
//  ScannerTests.swift
//  interpreter
//
//  Created by Matthew Reed on 12/4/24.
//

import Testing
@testable import interpreter

struct ScannerTests {
    @Test func scanSingleToken() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let source = "( ) ! < > = { } + - * / ; , : ."
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 17)
        #expect(scanner.tokens[0].tokenType == .LeftParen)
        #expect(scanner.tokens[1].tokenType == .RightParen)
        #expect(scanner.tokens[2].tokenType == .Bang)
        #expect(scanner.tokens[3].tokenType == .LessThan)
        #expect(scanner.tokens[4].tokenType == .GreaterThan)
        #expect(scanner.tokens[5].tokenType == .Equal)
        #expect(scanner.tokens[6].tokenType == .LeftBrace)
        #expect(scanner.tokens[7].tokenType == .RightBrace)
        #expect(scanner.tokens[8].tokenType == .Plus)
        #expect(scanner.tokens[9].tokenType == .Minus)
        #expect(scanner.tokens[10].tokenType == .Star)
        #expect(scanner.tokens[11].tokenType == .Slash)
        #expect(scanner.tokens[12].tokenType == .Semicolon)
        #expect(scanner.tokens[13].tokenType == .Comma)
        #expect(scanner.tokens[14].tokenType == .Colon)
        #expect(scanner.tokens[15].tokenType == .Dot)
        #expect(scanner.tokens[16].tokenType == .Eof)
    }

    @Test func scanMultiToken() async throws {
        let source = """
== <= >= // this is a comment
!= = = < = > = / / && ||
"""
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 17)
        #expect(scanner.tokens[0].tokenType == .EqualEqual)
        #expect(scanner.tokens[1].tokenType == .LessThanEqual)
        #expect(scanner.tokens[2].tokenType == .GreaterThanEqual)
        #expect(scanner.tokens[3].tokenType == .SlashSlash)
        #expect(scanner.tokens[4].tokenType == .Newline)
        #expect(scanner.tokens[5].tokenType == .BangEqual)
        #expect(scanner.tokens[6].tokenType == .Equal)
        #expect(scanner.tokens[7].tokenType == .Equal)
        #expect(scanner.tokens[8].tokenType == .LessThan)
        #expect(scanner.tokens[9].tokenType == .Equal)
        #expect(scanner.tokens[10].tokenType == .GreaterThan)
        #expect(scanner.tokens[11].tokenType == .Equal)
        #expect(scanner.tokens[12].tokenType == .Slash)
        #expect(scanner.tokens[13].tokenType == .Slash)
        #expect(scanner.tokens[14].tokenType == .And)
        #expect(scanner.tokens[15].tokenType == .Or)
        #expect(scanner.tokens[16].tokenType == .Eof)
    }
    
    @Test func scanIdentifier() async throws {
        let source = "let foo bar"
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 4)
        #expect(scanner.tokens[0].lexeme == "let")
        #expect(scanner.tokens[0].tokenType == .Let)
        #expect(scanner.tokens[1].lexeme == "foo")
        #expect(scanner.tokens[1].tokenType == .Identifier)
        #expect(scanner.tokens[2].lexeme == "bar")
        #expect(scanner.tokens[2].tokenType == .Identifier)
        #expect(scanner.tokens[3].tokenType == .Eof)
    }
    
    @Test func scanNumber() async throws {
        let source = "12 243 456 1.1 2.5 2"
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 7)
        #expect(scanner.tokens[0].lexeme == "12")
        #expect(scanner.tokens[0].tokenType == .Integer)
        #expect(scanner.tokens[1].lexeme == "243")
        #expect(scanner.tokens[1].tokenType == .Integer)
        #expect(scanner.tokens[2].lexeme == "456")
        #expect(scanner.tokens[2].tokenType == .Integer)
        #expect(scanner.tokens[3].lexeme == "1.1")
        #expect(scanner.tokens[3].tokenType == .Float)
        #expect(scanner.tokens[4].lexeme == "2.5")
        #expect(scanner.tokens[4].tokenType == .Float)
        #expect(scanner.tokens[5].lexeme == "2")
        #expect(scanner.tokens[5].tokenType == .Integer)
        #expect(scanner.tokens[6].tokenType == .Eof)
    }
    
    @Test func scanString() async throws {
        let source = "let var = \"Hello, world!\""
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 5)
        #expect(scanner.tokens[3].lexeme == "Hello, world!")
        #expect(scanner.tokens[3].tokenType == .String)
    }
    
    @Test func scanKeywords() async throws {
        let source = "let if else fun class return for while true false"
        let scanner = Scanner(source: source)
        try scanner.scan()
        #expect(scanner.tokens.count == 11)
        let tokens: [TokenType] = [.Let, .If, .Else, .Fun, .Class, .Return, .For, .While, .True, .False, .Eof]
        
        for (i, tokenType) in tokens.enumerated() {
            let t = scanner.tokens[i]
            #expect(t.tokenType == tokenType)
        }
    }
}

