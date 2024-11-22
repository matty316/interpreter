//
//  InterpreterTests.swift
//  interpreter
//
//  Created by Matthew Reed on 11/13/24.
//

import Testing
@testable import interpreter

struct InterpreterTests {
    
    func getToken(TokenType: Token.TokenType, line: Int) -> Token {
        return Token(type: TokenType, lexeme: TokenType.rawValue, line: line)
    }

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
10 / 5
10 * 5
(10 + 5) * 7
10 + 5 * 7
"""
        
        let scanner = Scanner(source: source)
        try scanner.scan()
        let parser = Parser(tokens: scanner.tokens)
        let program = try parser.parse()
        
        let expectedExpr: [Binary] = [
            Binary(left: Integer(value: 1), right: Integer(value: 2), op: Token(type: .Plus, lexeme: "+", line: 1)),
            Binary(left: Integer(value: 10), right: Integer(value: 3), op: Token(type: .GreaterThanEqual, lexeme: ">=", line: 2)),
            Binary(left: Integer(value: 5), right: Integer(value: 7), op: Token(type: .Plus, lexeme: "+", line: 2)),
            Binary(left: Integer(value: 10), right: Integer(value: 5), op: Token(type: .Slash, lexeme: "/", line: 3)),
            Binary(left: Integer(value: 10), right: Integer(value: 5), op: Token(type: .Star, lexeme: "*", line: 4)),
            Binary(left: Binary(left: Integer(value: 10), right: Integer(value: 5), op: getToken(TokenType: .Plus, line: 5)), right: Integer(value: 7), op: getToken(TokenType: .Star, line: 5)),
            Binary(left: Integer(value: 10), right: Binary(left: Integer(value: 5), right: Integer(value: 7), op: getToken(TokenType: .Star, line: 5)), op: getToken(TokenType: .Plus, line: 5)),
        ]
        
        #expect(program.stmts.count == 7)
        for (i, expr) in expectedExpr.enumerated() {
            let testStmt = program.stmts[i]
            guard let testStmt = testStmt as? Expression, let testExpr = testStmt.expr as? Binary else {
                #expect(Bool(false))
                return
            }
            
            #expect(testExpr.op.type == expr.op.type)
            
            if let left = testExpr.left as? Integer, let expectedLeft = expr.left as? Integer {
                #expect(left.value == expectedLeft.value)
            }
            
            if let right = testExpr.right as? Integer, let expectedRight = expr.right as? Integer {
                #expect(right.value == expectedRight.value)
            }
            
            if let left = testExpr.left as? Binary, let expectedLeft = expr.left as? Binary {
                let leftVal = left.left as! Integer
                let expectedLeftVal = left.left as! Integer
                let rightVal = left.right as! Integer
                let expectedRightVal = left.right as! Integer
                #expect(left.op.type == expectedLeft.op.type)
                #expect(leftVal.value == expectedLeftVal.value)
                #expect(rightVal.value == expectedRightVal.value)
            }
            
            if let right = testExpr.right as? Binary, let expectedRight = expr.right as? Binary {
                let leftVal = right.left as! Integer
                let expectedLeftVal = right.left as! Integer
                let rightVal = right.right as! Integer
                let expectedRightVal = right.right as! Integer
                #expect(right.op.type == expectedRight.op.type)
                #expect(leftVal.value == expectedLeftVal.value)
                #expect(rightVal.value == expectedRightVal.value)
            }
            
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
    
    @Test func parseLiteral() async throws {
        let source = """
1
1.3
true
false
null
"hell yeah"
"""
        let scanner = Scanner(source: source)
        try scanner.scan()
        let parser = Parser(tokens: scanner.tokens)
        let program = try parser.parse()
        
        let expected: [Expr] = [
            Integer(value: 1),
            FloatVal(value: 1.3),
            Boolean(value: true),
            Boolean(value: false),
            Null(),
            StringVal(value: "hell yeah"),
        ]
        
        #expect(program.stmts.count == 6)
        
        for (i, expr) in expected.enumerated() {
            let stmt = program.stmts[i] as! Expression
            let testExpr = stmt.expr
            
            if let expr = expr as? Integer {
                let int = testExpr as! Integer
                #expect(expr.value == int.value)
            }
            
            if let expr = expr as? FloatVal {
                let float = testExpr as! FloatVal
                #expect(expr.value == float.value)
            }
            
            if let expr = expr as? StringVal {
                let string = testExpr as! StringVal
                #expect(expr.value == string.value)
            }
            
            if let expr = expr as? Boolean {
                let bool = testExpr as! Boolean
                #expect(expr.value == bool.value)
            }
            
            if expr is Null {
                #expect(testExpr is Null)
            }
        }
    }
    
    @Test(arguments: [
        ("2 * 5", 10),
        ("1 + 2", 3),
        ("10 / 5", 2),
        ("10 - 5", 5),
        ("-1", -1),
    ])
    func evalIntExpressions(exp: (source: String, answer: Int)) async throws {
        let scanner = Scanner(source: exp.source)
        try scanner.scan()
        let parser = Parser(tokens: scanner.tokens)
        let program = try parser.parse()
        let eval = Evaluator(program: program)
        let answer = try eval.eval()
        if let answer = answer as? Int {
            #expect(answer == exp.answer)
        }
    }
    
    @Test(arguments: [
        ("1 / 5", 0.2),
        ("1.3 * 2.0", 2.6),
        ("1.3 * 2", 2.6)
    ])
    func evalFloatExpressions(exp: (source: String, answer: Double)) async throws {
        let scanner = Scanner(source: exp.source)
        try scanner.scan()
        let parser = Parser(tokens: scanner.tokens)
        let program = try parser.parse()
        let eval = Evaluator(program: program)
        let answer = try eval.eval()
        if let answer = answer as? Double {
            #expect(answer == exp.answer)
        }
    }
    
    @Test(arguments: [
        ("!true", false),
        ("!false", true),
        ("false", false),
        ("true", true),
        ("1 < 3", true),
        ("2 < 1", false),
        ("3 > 2", true),
        ("3 < 2", false),
        ("3 >= 3", true),
        ("3 <= 3", true),
        ("3 >= 2", true),
        ("3 <= 2", false),
        ("3 == 3", true),
        ("2 != 3", true),
        ("2 != 2", false),
        ("\"hell yeah\" == \"hell yeah\"", true),
        ("\"hell yeah\" == \"hell no\"", false),
    ])
    func evalBoolExpressions(exp: (source: String, answer: Bool)) async throws {
        let scanner = Scanner(source: exp.source)
        try scanner.scan()
        let parser = Parser(tokens: scanner.tokens)
        let program = try parser.parse()
        let eval = Evaluator(program: program)
        let answer = try eval.eval()
        if let answer = answer as? Bool{
            #expect(answer == exp.answer)
        }
    }
    
    @Test(arguments: [
        ("\"hell\" + \" yeah\"", "hell yeah"),
    ])
    func evalStringExpressions(exp: (source: String, answer: String)) async throws {
        let scanner = Scanner(source: exp.source)
        try scanner.scan()
        let parser = Parser(tokens: scanner.tokens)
        let program = try parser.parse()
        let eval = Evaluator(program: program)
        let answer = try eval.eval()
        if let answer = answer as? String {
            #expect(answer == exp.answer)
        }
    }
    
    @Test(arguments: [
        ("let variable = 1\nvariable", 1),
        ("let variable = 1; variable = 2; variable", 2)
    ])
    func globalVars(exp: (source: String, answer: Int)) async throws {
        let scanner = Scanner(source: exp.source)
        try scanner.scan()
        let parser = Parser(tokens: scanner.tokens)
        let program = try parser.parse()
        let eval = Evaluator(program: program)
        let answer = try eval.eval()
        if let answer = answer as? Int {
            #expect(answer == exp.answer)
        }
    }
    
    @Test(arguments: zip(["let variable = 2; variable = 3"], [(3, "variable")]))
    func parseAssign(source: String, exp: (val: Int, name: String)) async throws {
        let scanner = Scanner(source: source)
        try scanner.scan()
        let parser = Parser(tokens: scanner.tokens)
        let program = try parser.parse()
        guard let exprStmt = program.stmts.last as? Expression, let assign = exprStmt.expr as? Assign else {
            return
        }
        
        #expect(assign.name == exp.name)
        #expect((assign.value as! Integer).value == exp.val)
    }
    
    @Test func block() async throws {
        let source = """
let var1 = "global 1"
let var2 = "global 2"
let var3 = "global 3"

{
    let var1 = "local 1"
    let var2 = "local 2"
    let var3 = "local 3"
}

var1
"""
        
        let scanner = Scanner(source: source)
        try scanner.scan()
        let parser = Parser(tokens: scanner.tokens)
        let program = try parser.parse()
        let eval = Evaluator(program: program)
        let answer = try eval.eval()
        
        #expect(answer as! String == "global 1")
    }
}
