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

struct Expression: Stmt {
    let expr: Expr
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

struct Float: Expr {
    let value: Double
}

struct Null: Expr {}
