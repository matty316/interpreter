//
//  ast.swift
//  interpreter
//
//  Created by Matthew Reed on 11/15/24.
//

protocol Stmt {}
protocol Expr {}

struct Program {
    let stmts: [Stmt]
}

struct Function: Stmt {
    let name: Token
    let params: [Token]
    let body: [Stmt]
}

struct IfExpr: Expr {
    let condition: Expr
    let thenBranch: Block
    let elseBranch: Block?
}

struct ExpressionStmt: Stmt {
    let expr: Expr
}

struct LetStmt: Stmt {
    let name: String
    let initializer: Expr?
}

struct Block: Stmt {
    let stmts: [Stmt]
}

struct Assignment: Expr {
    let name: Token
    let value: Expr
}

struct Binary: Expr {
    let left: Expr
    let right: Expr
    let op: Token
}

struct Unary: Expr {
    let op: Token
    let right: Expr
}

struct Integer: Expr {
    let value: Int
}

struct Boolean: Expr {
    let value: Bool
}

struct StringVal: Expr {
    let value: String
}

struct FloatVal: Expr {
    let value: Double
}

struct Null: Expr {}

struct Identifier: Expr {
    let name: String
}

struct Assign: Expr {
    let name: String
    let value: Expr
}

struct While: Stmt {
    let condition: Expr
    let body: Block
}

struct For: Stmt {
    let initializer: Stmt
    let condition: Expr
    let increment: Expr
    let body: Block
}
