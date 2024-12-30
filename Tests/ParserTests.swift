//
//  ParserTests.swift
//  interpreter
//
//  Created by Matthew Reed on 12/4/24.
//

import Testing
@testable import interpreter

struct ParserTests {
    func parse(input: String) -> [Stmt] {
        let s = Scanner(source: input)
        try! s.scan()
        let p = Parser(tokens: s.tokens)
        return try! p.parse().stmts
    }
    
    func getToken(TokenType: TokenType, line: Int) -> Token {
        return Token(type: TokenType, lexeme: TokenType.rawValue, line: line)
    }
    
    @Test(arguments: ["end", "end;", "end\n"])
    func testEndLine(input: String) {
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! Identifier
        #expect(expr.name == "end")
    }
    
    @Test(arguments: [
        ("let string = \"Hell Yeah\"", "string", "Hell Yeah")
    ])
    func testParseLet(test: (input: String, name: String, initializer: String)) {
        let stmts = parse(input: test.input)
        #expect(stmts.count == 1)
        let letStmt = stmts.first as! LetStmt
        #expect(letStmt.name == test.name)
        let expr = letStmt.initializer as! StringVal
        #expect(expr.value == test.initializer)
    }
    
    @Test(arguments: zip([
       "1", "233"
    ],[
        1, 233
    ]))
    func testInts(input: String, exp: Int) {
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! Integer
        #expect(expr.value == exp)
    }
    
    @Test(arguments: zip([
       "1.2", "233.333"
    ],[
        1.2, 233.333
    ]))
    func testFloats(input: String, exp: Double) {
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! FloatVal
        #expect(expr.value == exp)
    }
    
    @Test(arguments: zip(["true", "false"], [true, false]))
    func testBoolean(input: String, exp: Bool) {
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! Boolean
        #expect(expr.value == exp)
    }
    
    @Test(arguments: zip([
       "\"Hell Yeah\""
    ],[
        "Hell Yeah"
    ]))
    func testStrings(input: String, exp: String) {
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! StringVal
        #expect(expr.value == exp)
    }
    
    @Test(arguments: zip([
       "Hell",
    ],[
        "Hell",
    ]))
    func testIdent(input: String, exp: String) {
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! Identifier
        #expect(expr.name == exp)
    }
    
    @Test(arguments: zip([
        "1 + 2",
        "1 - 2",
        "1 * 2",
        "1 / 2",
        "1 < 2",
        "1 > 2",
        "1 >= 2",
        "1 <= 2",
        "1 == 2",
        "1 != 2"
    ], [
        (1, 2, Token(type: .Plus)),
        (1, 2, Token(type: .Minus)),
        (1, 2, Token(type: .Star)),
        (1, 2, Token(type: .Slash)),
        (1, 2, Token(type: .LessThan)),
        (1, 2, Token(type: .GreaterThan)),
        (1, 2, Token(type: .GreaterThanEqual)),
        (1, 2, Token(type: .LessThanEqual)),
        (1, 2, Token(type: .EqualEqual)),
        (1, 2, Token(type: .BangEqual)),
    ]))
    func testBinary(input: String, exp: (left: Int, right: Int, op: Token)) {
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! Binary
        
        let left = expr.left as! Integer
        #expect(left.value == exp.left)
        let right = expr.right as! Integer
        #expect(right.value == exp.right)
        
        #expect(expr.op.tokenType == exp.op.tokenType)
    }
    
    @Test(arguments: zip(["-1"], [1]))
    func testIntegerPrefix(input: String, exp: Int) {
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! Unary
        let right = expr.right as! Integer
        #expect(right.value == exp)
        #expect(expr.op.tokenType == .Minus)
    }
    
    @Test(arguments: zip(["!true", "!false"], [true, false]))
    func testBoolPrefix(input: String, exp: Bool) {
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! Unary
        let right = expr.right as! Boolean
        #expect(right.value == exp)
        #expect(expr.op.tokenType == .Bang)
    }
    
    @Test func testIf() {
        let input = """
if 1 < 2 {
    "hell yes"
}
"""
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! IfExpr
        let condition = expr.condition as! Binary
        testBinaryExpr(expr: condition, left: 1, right: 2, op: .LessThan)
        let thenBranch = expr.thenBranch.stmts.first as! ExpressionStmt
        let thenExpr = thenBranch.expr as! StringVal
        #expect(thenExpr.value == "hell yes")
    }
    
    @Test func testIfElse() {
        let input = """
if 1 < 2 {
    "hell yes"
} else {
    "hell no"
}
"""
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! IfExpr
        let condition = expr.condition as! Binary
        testBinaryExpr(expr: condition, left: 1, right: 2, op: .LessThan)
        let thenBranch = expr.thenBranch.stmts.first as! ExpressionStmt
        let thenExpr = thenBranch.expr as! StringVal
        #expect(thenExpr.value == "hell yes")
        let elseBranch = expr.elseBranch?.stmts.first as! ExpressionStmt
        let elseExpr = elseBranch.expr as! StringVal
        #expect(elseExpr.value == "hell no")
    }
    
    func testBinaryExpr(expr: Binary, left: Int, right: Int, op: TokenType) {

        #expect(left == (expr.left as! Integer).value)
        #expect(right == (expr.right as! Integer).value)
        #expect(expr.op.tokenType == op)
    }
    
    @Test func testGrouping() {
        let input = "(1 + 2) * 3"
        let stmt = parse(input: input).first as! ExpressionStmt
        let expr = stmt.expr as! Binary
        let left = expr.left as! Binary
        let right = expr.right as! Integer
        
        testBinaryExpr(expr: left, left: 1, right: 2, op: .Plus)
        #expect(right.value == 3)
    }
    
    @Test func parseBinary() async throws {
        let source = """
1 + 2
10 >= 3; 5 + 7
10 / 5
10 * 5
(10 + 5) * 7
10 + 5 * 7
true && false
true || false
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
            Binary(left: Boolean(value: true), right: Boolean(value: false), op: Token(type: .And)),
            Binary(left: Boolean(value: true), right: Boolean(value: false), op: Token(type: .Or))
        ]
        
        #expect(program.stmts.count == 9)
        for (i, expr) in expectedExpr.enumerated() {
            let testStmt = program.stmts[i]
            guard let testStmt = testStmt as? ExpressionStmt, let testExpr = testStmt.expr as? Binary else {
                #expect(Bool(false))
                return
            }
            
            #expect(testExpr.op.tokenType == expr.op.tokenType)
            
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
                #expect(left.op.tokenType == expectedLeft.op.tokenType)
                #expect(leftVal.value == expectedLeftVal.value)
                #expect(rightVal.value == expectedRightVal.value)
            }
            
            if let right = testExpr.right as? Binary, let expectedRight = expr.right as? Binary {
                let leftVal = right.left as! Integer
                let expectedLeftVal = right.left as! Integer
                let rightVal = right.right as! Integer
                let expectedRightVal = right.right as! Integer
                #expect(right.op.tokenType == expectedRight.op.tokenType)
                #expect(leftVal.value == expectedLeftVal.value)
                #expect(rightVal.value == expectedRightVal.value)
            }
            
        }
        guard let stmt = program.stmts.first as? ExpressionStmt, let expr = stmt.expr as? Binary else {
            #expect(Bool(false))
            return
        }
        #expect(expr.op.tokenType == .Plus)
        guard let left = expr.left as? Integer, let right = expr.right as? Integer else {
            #expect(Bool(false))
            return
        }
        
        #expect(left.value == 1)
        #expect(right.value == 2)
    }
    
    @Test func testAssign() {
        let source = "x = 1"
        let stmt = parse(input: source).first as! ExpressionStmt
        let expr = stmt.expr as! Assign
        
        #expect(expr.name == "x")
        let val = expr.value as! Integer
        #expect(val.value == 1)
    }
    
    @Test func testWhile() {
        let source = """
while true {
    "infinity"
} 
"""
        let stmt = parse(input: source).first as! While
        let exp = While(condition: Boolean(value: true), body: Block(stmts: [ExpressionStmt(expr: StringVal(value: "infinity"))]))
        
        let condition = stmt.condition as! Boolean
        let expCondition = exp.condition as! Boolean
        #expect(condition.value == expCondition.value)
        
        let body = (stmt.body.stmts.first as! ExpressionStmt).expr as! StringVal
        let expBody = (exp.body.stmts.first as! ExpressionStmt).expr as! StringVal
        #expect(body.value == expBody.value)
    }
    
    @Test func testFor() {
        let source = """
for let i = 0; i < 10; i = i + 1 {
    "increment"
}
"""
        let stmt = parse(input: source).first as! For
        let initializer = stmt.initializer as! LetStmt
        let condition = stmt.condition as! Binary
        let increment = stmt.increment as! Assign
    }
}
