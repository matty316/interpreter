//
//  EvalTests.swift
//  interpreter
//
//  Created by Matthew Reed on 12/4/24.
//

import Testing
@testable import interpreter

struct EvalTests {
    func getResult(source: String) throws -> Any? {
        let s = Scanner(source: source)
        try s.scan()
        let p = Parser(tokens: s.tokens)
        let program = try p.parse()
        let e = Evaluator(program: program)
        let result = try e.eval()
        return result
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
    
    @Test(arguments: zip(["let variable = 2; variable = 3; variable"], [3]))
    func assign(source: String, exp: Int) async throws {
        let res = try getResult(source: source)
        
        #expect(res as! Int == exp)
    }
    
    @Test func testBlock() {
        let source = """
let variable = 12
{
    let variable = 13
}
variable
"""
        
        let res = try! getResult(source: source) as! Int
        #expect(res == 12)
    }
    
    @Test(arguments: zip([
        "if true { 2 }",
        "if false { 2 }",
        "if 1 < 2 { 3 }",
        "if 1 > 2 { 3 }",
        "if true { 2 } else { 3 }",
        "if false { 2 } else { 3 }"
    ],[2, nil, 3, nil, 2, 3])) func testEvalIf(input: String, exp: Int?) {
        let res = try! getResult(source: input)
        if let exp = exp {
            let num = (res as! ExpressionStmt).expr as! Integer
            #expect(num.value == exp)
        } else {
            #expect(res == nil)
        }
    }
}
