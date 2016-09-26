

# Reverse Programmer Notation (RProgN)

_Developed by William Lemon_

# Abstract

The idea of this language was to try to write a stack based programming language using the syntax of Reverse Polish Notation. &quot;_a b +&quot;._ Although languages already exist that do this, eg. PostScript, None do it so that any **RPN** would implicitly work. Essentially, this was designed to Turing Complete Reverse Polish Notation.

Initially written in Lua, RProgN is an interpreted esoteric language. It contains two memory blocks, the **Reg**  **&lt;Stack&gt;** and the **Mem**  **&lt;Associative Array&gt;**.

The syntax itself is split up into whitespace separated &#39;functions&#39;, which are run from left to right. In RProgN, constants do not exist, instead, each number and string counts as a default &#39;function&#39;, which can be overwritten.

Strings are the only things that do not follow this rule, instead, when the interpreter is scanning across a word and finds either a &quot; or a &#39;, the word is instead changed to a constructor for a string. See Strings.

# Strings

In RProgN, Hello\_World&#39;&#39; is a valid constructor for a string which places, (Without quotes) &quot;Hello\_World&quot; onto the stack.  Spaces can exist in string constructors when between a pair of quotes, such that &#39;Hello World&#39; is the constructor for &quot;Hello World&quot; (Without the quotes).  Escapes, thus, do not exist in RProgN, and instead the programmer is expected to use the literal versons of these characters enclosed in strings. To represent a &#39;, one could do &#39;Hello &#39;&quot;&#39;&quot;&#39;World&#39;&quot;&#39;&quot;, This is a closing apostrophe, followed by an opening quotation mark, which then can freely use the apostrophe, than the closing quotation mark. Then, another apostrophe can be used to finish writing &quot;World&quot;. Because a whitespace character was not used between the two different quote Types, the word never ended, and thus, it is automatically appended. More simply, one should use &quot;Hello &#39;World&#39;&quot;. New lines, null characters and that in the like do not terminate a string, only the same mark used to start the string can, as such, new lines and that in the like can be represented via a quote, followed by a literal new line, than another quote.

# Flow of Control

Flow of Control in RProgN is handled through specific functions which push the read pointer to various parts of the script. As per default, the functions &quot;if&quot;, &quot;while&quot;, &quot;for&quot;, &quot;function&quot;, and &quot;else&quot; (yes, else is a function) will push the pointer ahead of the matching &#39;end&#39; or &#39;else&#39;. When encountered, the functions themselves determine the correct information, such as the case for &#39;for&#39; statements, and the &#39;(i=a; i&lt;=b; i+=c)&#39; values for the for loop, and will either continue reading if it should, or shunt to the matching else/end if it should do that instead.

## &#39;if&#39; statements

The If statement simply peeks the top of the stack, checks if it&#39;s a truthy value, and will either continue reading the script, or shunt to the matching else/end otherwise.

## &#39;while&#39; statements

While statements work exactly like the if statement, except when they encounter their matching end, they return to the while statement, and check the top of the stack again, and will repeat this until the top of the stack is falsey when encountering the while.

## &#39;for&#39; statements

When a for statement is encounted, the top 3 values of the stack are popped.

In order from top to bottom, the values are &#39;a&#39;, &#39;b&#39;, and &#39;c&#39;.
An iteratoris created, starting at value a, until and including value b, it will increment by c each loop, which may be negative or 0. In each iteration, the value of the iterator is pushed to the top of the stack.

## &#39;else&#39; statement

The else statement, or more accurately, function, will regardless of contents, jump to the matching end.  As the else statement is usable in all flow of control functions, it&#39;s possible to use it to define an, &#39;After this is finished, do this&#39; type statement. Yet it&#39;s hardly useful for anything other than if statements.

# Functions

Functions are the main data type of RProgN, each constant value is actually defined as a function that pushes what it represents to the reg. &#39;1&#39; is internally defined (in the Lua representation) as &#39;reg.push(1)&#39;. As such, it&#39;s possible to redefine the nature of (almost) everything in RProgN, the only exception being String Constructors, which require special behaviour to exist. This includes flow of control functions.

## Default Functions

As per default, RProgN should contain the following functions where a,b,c... are values from the top of the stack down, implicitly popped.

- &#39;-&#39; : pushes b - a
- &#39;\*&#39;: pushes b \* a
- &#39;/&#39;: pushes b / a
- &#39;//&#39;: pushes the integral division of b / a
- &#39;%&#39;: Returns the modulas of a % b
- &#39;^&#39;: pushes b to the power of a
- &#39;]&#39;: clones the top of the stack
- &#39;[&#39;: pops the top value of the stack
- &#39;\&#39;: pushes a, then b, so that a and b switch places.
- &#39;==&#39;: pushes true if a = b, false otherwise
- &#39;=&#39;: See above
- &#39;&gt;=&#39;, &#39;&gt;&#39;, &#39;&lt;=&#39;, &#39;&lt;&#39;, &#39;!=&#39;: Comparative functions, such that a &#39;&#39; b
- &#39;getraw&#39;: pushes the value associated with a to the stack. Used normally get functions instead of calling them
- &#39;Q&#39;: pushes the raw inputted string of the current function, or code itself to the stack.
- &#39;asoc&#39;: Associates value b to the string a, such that writing a will be interpreted as a call to b. If a is a stack, then b will be a reference to c on the stack a.
- &#39;recall&#39;: Similar to getraw, but from the global mem table. Depreciated.
- &#39;char&#39;: Pushes the ASCII character associated with a
- &#39;byte&#39;: Pushes the ASCII value of a
- &#39;max&#39;: pushes the larger of a and b
- &#39;min&#39;: pushes the smaller of a and b
- &#39;p&#39;: outputs a
- &#39;rand&#39;: pushes a random float between a and b
- &#39;randomseed&#39;: seed the random generator with a
- &#39;time&#39;: pushes the current os time in Unix Time
- &#39;len&#39;: pushes the size of a, the such that if a is a string, then the length of that string, or if a is a stack, the size of that stack
- &#39;floor&#39;: pushes the floor of a
- &#39;sub&#39;: pushes the substring of c between a and b
- &#39;do&#39;: Interpret a as RProgN
- &#39;stack&#39;: pushes a new stack (Which also doubles as an associative array)
- &#39;push&#39;: push a to b
- &#39;pop&#39;: pop from a to the stack
- &#39;peek&#39;: push the top value of a
- &#39;mem&#39;: push the mem associative array
- &#39;reg&#39;: push the reg stack, to the reg stack...
- &#39;get&#39;: push the value of a from array b
- &#39;set&#39;: set the value of b of array c to a
- &#39;truthy&#39;: push true if the value is truthy, false otherwise.
- &#39;debug&#39;: Output debug information.
- &#39;local&#39;: push the &#39;local&#39; array to the stack. Useful with asoc, as local is also accessible from the current namespace.
- &#39;tostack&#39;: push a stack containing each individual substring of a to the stack.
- &#39;inverse&#39;: push an upside down version of a

## Defining Functions

Defining a function is simply done with a &#39;function&#39; &#39;end&#39; pair, such that.

function

-- CODE GOES HERE --

end

The above snippet would push a function containing the inner code to the top of the stack. To name it, and as such, use it, one would require associating it to a name, as below.

function

-- CODE GOES HERE --

end &#39;HelloWorld&#39; asoc

