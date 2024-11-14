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
        #expect(scanner.tokens.count == 14)
        #expect(scanner.tokens[0].type == .EqualEqual)
        #expect(scanner.tokens[1].type == .LessThanEqual)
        #expect(scanner.tokens[2].type == .GreaterThanEqual)
        #expect(scanner.tokens[3].type == .SlashSlash)
        #expect(scanner.tokens[4].type == .BangEqual)
        #expect(scanner.tokens[5].type == .Equal)
        #expect(scanner.tokens[6].type == .Equal)
        #expect(scanner.tokens[7].type == .LessThan)
        #expect(scanner.tokens[8].type == .Equal)
        #expect(scanner.tokens[9].type == .GreaterThan)
        #expect(scanner.tokens[10].type == .Equal)
        #expect(scanner.tokens[11].type == .Slash)
        #expect(scanner.tokens[12].type == .Slash)
        #expect(scanner.tokens[13].type == .Eof)
    }
}
