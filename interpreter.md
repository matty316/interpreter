---
author: matty
---

# building a programming language | tree walk interpreter
by matty

---

# example code

```swift
let var = 1
let anotherVar = "string"

if var == 1 {
    print(true)
}

let array = [1, 2, 3]

for item in array {
    print(item)
}

fun count(array) {
    return array.count
}

count(array)

class Rect {
    let length
    let width
    
    fun area() {
        return length * width
    }
}

```

---

# why

- mostly for learning and it really improved my understanding of programming languages when i first built one
- boredom

---

# what is a tree walk interpreter

- as opposed to a compiler (which translates source code into machine code or assembly) an interpreter will parse the code and execute it right away line by line
- this is a lot slower than if the code was compiled but easier to implement and more portable
- the tree walk comes from the fact we will create a tree structure to represent the source code and "walk" the tree to execute the code

---

# why a tree walk intrerpreter

- it's a good introduction to interpreters and compilers
- it's the easiest to implement (i will build a compiler in a future video)
- i have done it before (you can watch me struggle in a different video)

---

# the scanner

- the scanner's job is to turn a source code file into a list of tokens
- a token represents something that the launguange needs to know about 
    - a semicolon, a number, a word, etc 
- we take those tokens and pass the to...

---

# the parser

- the parser's job is to take the tokens and create a structure to respresent the code
- we will be building a recursive descent parser
- this will loop thru our tokens and call functions recursively based on the precedence of the diff statements and expressions in our language
- it will build our *abstract syntax tree* by returning objects from those functions 

---

# the evaluator

- this is the last piece of our interpreter 
    - kind of. you can add a million different steps if you want (i.e. optimization)
- this step's job is to evaluate the expressions and statements we parsed
- we will start by parsing expressions and then statements
- we must also decide how to respresent the values in our language

| Our Interpreter | Swift  |
| --------------- | -----  |
| AnyValue        | Any    |
| Null            | Nil    |
| Boolean         | Bool   |
| Integer         | Int    |
| Float           | Double |
| String          | String |

---

# example eval code

```swift
func evalExpr(_ expr: Expr) -> Any {
    if expr is Binary {
        return evalBinary(expr)
    } else if let expr = expr as? Integer {
        return expr.value
    }
}

func evalBinary(_ expr: Expr) -> Any {
    let left = evalExpr(expr.left)
    let right = evalExpr(expr.right)
    switch expr.op.type {
        case .plus:
            if let left = left as? Int, let right = right as? Int {
                return left + right
            }
        default: throw Error
    }
}

```

---
# resources

- [crafting interpreters](https://craftinginterpreters.com)
- [writing an interpreter in go](https://interpreterbook.com)


