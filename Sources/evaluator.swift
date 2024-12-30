//
//  evaluator.swift
//  interpreter
//
//  Created by Matthew Reed on 11/17/24.
//

enum RuntimeError: Error {
    case General
    case Unimplemented
    case InvalidOperand
}

class Evaluator {
    let program: Program
    var env = Env()
    
    init(program: Program) {
        self.program = program
    }
    
    func eval() throws -> Any? {
        var last: Any? = nil
        for stmt in program.stmts {
            last = try evalStmt(stmt)
        }
        return last
    }
    
    @discardableResult
    func evalStmt(_ stmt: Stmt) throws -> Any? {
        switch stmt {
        case let stmt as ExpressionStmt: return try evalExpession(stmt)
        case let stmt as LetStmt: return try evalLetStmt(stmt)
        case let whileStmt as While: return try evalWhile(whileStmt)
        case let forStmt as For: return try evalFor(forStmt)
        case let stmt as Block: return try evalBlock(stmt, environment: Env(enclosing: env))
        default: throw RuntimeError.General
        }
    }
    
    func evalIf(_ expr: IfExpr) throws -> Any? {
        if try isTruthy(expr.condition) {
            return try evalStmt(expr.thenBranch)
        } else if let elseBranch = expr.elseBranch {
            return try evalStmt(elseBranch)
        }
        return nil
    }
    
    func isTruthy(_ expr: Expr) throws -> Bool {
        guard let truthy = try evalExpr(expr) as? Bool else {
            throw RuntimeError.InvalidOperand
        }
        return truthy
    }
    
    func evalExpession(_ stmt: ExpressionStmt) throws -> Any? {
        let expr = stmt.expr
        return try evalExpr(expr)
    }
    
    func evalBlock(_ stmt: Block, environment: Env) throws -> Any? {
        let prev = env
        env = environment
        for stmt in stmt.stmts {
            try evalStmt(stmt)
        }
        env = prev
        return stmt.stmts.last
    }
    
    func evalLetStmt(_ stmt: LetStmt) throws -> Any? {
        var value: Any? = nil
        
        if let initializer = stmt.initializer {
            value = try evalExpr(initializer)
        }
        
        env.define(name: stmt.name, value: value)
        return nil
    }
    
    func evalExpr(_ expr: Expr) throws -> Any? {
        switch expr {
        case let binary as Binary: return try evalBinary(binary)
        case let integer as Integer: return integer.value
        case let unary as Unary: return try evalUnary(unary)
        case let boolean as Boolean: return boolean.value
        case let string as StringVal: return string.value
        case let float as FloatVal: return float.value
        case let variable as Identifier: return try env.get(name: variable.name)
        case let assign as Assign: return try evalAssign(assign)
        case let ifExpr as IfExpr: return try evalIf(ifExpr)
        case is Null: return nil
        default: throw RuntimeError.General
        }
    }
    
    func evalAssign(_ expr: Assign) throws -> Any? {
        let value = try evalExpr(expr.value)
        try env.assign(name: expr.name, value: value)
        return value
    }
    
    func evalBinary(_ expr: Binary) throws -> Any {
        let op = expr.op
        
        if op.tokenType == .And || op.tokenType == .Or {
            return try evalConditional(left: expr.left, right: expr.right, op: op)
        }
        
        let left = try evalExpr(expr.left)
        let right = try evalExpr(expr.right)
        
        switch op.tokenType {
        case .Plus:
            if let left = left as? Int, let right = right as? Int {
                return left + right
            } else if let left = left as? Double, let right = right as? Double {
                return left + right
            } else if let left = left as? String, let right = right as? String {
                return left + right
            } else if let left = left as? Double, let right = right as? Int {
                return left + Double(right)
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left) + right
            }
        case .Minus:
            if let left = left as? Int, let right = right as? Int {
                return left - right
            } else if let left = left as? Double, let right = right as? Double {
                return left - right
            } else if let left = left as? Double, let right = right as? Int {
                return left - Double(right)
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left) - right
            }
        case .Star:
            if let left = left as? Int, let right = right as? Int {
                return left * right
            } else if let left = left as? Double, let right = right as? Double {
                return left * right
            } else if let left = left as? Double, let right = right as? Int {
                return left * Double(right)
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left) * right
            }
        case .Slash:
            if let left = left as? Int, let right = right as? Int {
                return left / right
            } else if let left = left as? Double, let right = right as? Double {
                return left / right
            } else if let left = left as? Double, let right = right as? Int {
                return left / Double(right)
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left) / right
            }
        case .LessThan:
            if let left = left as? Int, let right = right as? Int {
                return left < right
            } else if let left = left as? Double, let right = right as? Double {
                return left < right
            } else if let left = left as? Double, let right = right as? Int {
                return left < Double(right)
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left) < right
            }
        case .LessThanEqual:
            if let left = left as? Int, let right = right as? Int {
                return left <= right
            } else if let left = left as? Double, let right = right as? Double {
                return left <= right
            } else if let left = left as? Double, let right = right as? Int {
                return left <= Double(right)
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left) <= right
            }
        case .GreaterThan:
            if let left = left as? Int, let right = right as? Int {
                return left > right
            } else if let left = left as? Double, let right = right as? Double {
                return left > right
            } else if let left = left as? Double, let right = right as? Int {
                return left > Double(right)
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left) > right
            }
        case .GreaterThanEqual:
            if let left = left as? Int, let right = right as? Int {
                return left >= right
            } else if let left = left as? Double, let right = right as? Double {
                return left >= right
            } else if let left = left as? Double, let right = right as? Int {
                return left >= Double(right)
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left) >= right
            }
        case .EqualEqual:
            if let left = left as? Int, let right = right as? Int {
                return left == right
            } else if let left = left as? Double, let right = right as? Double {
                return left == right
            } else if let left = left as? Double, let right = right as? Int {
                return left == Double(right)
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left) == right
            } else if let left = left as? Bool, let right = right as? Bool {
                return left == right
            } else if let left = left as? String, let right = right as? String {
                return left == right
            }
        case .BangEqual:
            if let left = left as? Int, let right = right as? Int {
                return left != right
            } else if let left = left as? Double, let right = right as? Double {
                return left != right
            } else if let left = left as? Double, let right = right as? Int {
                return left != Double(right)
            } else if let left = left as? Int, let right = right as? Double {
                return Double(left) != right
            } else if let left = left as? Bool, let right = right as? Bool {
                return left != right
            } else if let left = left as? String, let right = right as? String {
                return left != right
            }
        default: break
        }
        throw RuntimeError.General
    }
    
    func evalConditional(left: Expr, right: Expr, op: Token) throws -> Bool {
        switch op.tokenType {
        case .And:
            if try !isTruthy(left) {
                return false
            }
            
            return try isTruthy(right)
        case .Or:
            if try isTruthy(left) {
                return true
            }
            
            return try isTruthy(right)
        default: throw RuntimeError.InvalidOperand
        }
    }
    
    func evalUnary(_ expr: Unary) throws -> Any {
        let op = expr.op
        let right = try evalExpr(expr.right)
        
        switch op.tokenType {
        case .Bang:
            if let right = right as? Bool {
                return !right
            }
        case .Minus:
            if let right = right as? Int {
                return -right
            }
        default: break
        }
        throw RuntimeError.General
    }
    
    func evalWhile(_ whileStmt: While) throws -> Any? {
        while try isTruthy(whileStmt.condition) {
            try evalStmt(whileStmt.body)
        }
        return nil
    }
    
    func evalFor(_ forStmt: For) throws -> Any? {
        guard let initializer = forStmt.initializer as? LetStmt else {
            throw RuntimeError.General
        }
        _ = try evalLetStmt(initializer)
        while try isTruthy(forStmt.condition) {
            try evalStmt(forStmt.body)
            guard let assign = forStmt.increment as? Assign else {
                throw RuntimeError.General
            }
            _ = try evalAssign(assign)
        }
        
        return nil
    }
}
