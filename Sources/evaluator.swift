//
//  evaluator.swift
//  interpreter
//
//  Created by Matthew Reed on 11/17/24.
//

enum RuntimeError: Error {
    case General
    case Unimplemented
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
    
    func evalStmt(_ stmt: Stmt) throws -> Any? {
        switch stmt {
        case let stmt as Expression: return try evalExpession(stmt)
        case let stmt as VarStmt: return try evalVarStmt(stmt)
        case let stmt as Block: return try evalBlock(stmt, environment: Env(enclosing: env))
        default: throw RuntimeError.General
        }
    }
    
    func evalExpession(_ stmt: Expression) throws -> Any? {
        let expr = stmt.expr
        return try evalExpr(expr)
    }
    
    func evalBlock(_ stmt: Block, environment: Env) throws -> Any? {
        let prev = env
        env = environment
        for stmt in stmt.stmts {
            _ = try evalStmt(stmt)
        }
        env = prev
        return nil
    }
    
    func evalVarStmt(_ stmt: VarStmt) throws -> Any? {
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
        case let variable as Var: return try env.get(name: variable.name)
        case let assign as Assign: return try evalAssign(assign)
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
        let left = try evalExpr(expr.left)
        let right = try evalExpr(expr.right)
        
        switch op.type {
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
    
    func evalUnary(_ expr: Unary) throws -> Any {
        let op = expr.op
        let right = try evalExpr(expr.right)
        
        switch op.type {
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
}
