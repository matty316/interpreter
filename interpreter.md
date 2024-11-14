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

# resources

[crafting interpreters](https://craftinginterpreters.com)
[writing an interpreter in go](https://interpreterbook.com)

