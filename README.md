

# Reverse Programmer Notation (RProgN)

_Developed by William Lemon_

# Abstract

The idea of this language was to try to write a stack based programming language using the syntax of Reverse Polish Notation. &quot;_a b +&quot;._ Although languages already exist that do this, eg. PostScript, None do it so that any **RPN** would implicitly work. Essentially, this was designed to Turing Complete Reverse Polish Notation.

Initially written in Lua, RProgN is an interpreted esoteric language. It contains two memory blocks, the **Reg**  **&lt;Stack&gt;** and the **Mem**  **&lt;Associative Array&gt;**.

The syntax itself is split up into whitespace separated &#39;functions&#39;, which are run from left to right. In RProgN, constants do not exist, instead, each number counts as a default &#39;function&#39;, which can be overwritten.

Strings are the only things that do not follow this rule, instead, when the interpreter is scanning across a word and finds either a &quot; or a &#39;, the word is instead changed to a constructor for a string.

# Note

The majority of this Readme was horrifyingly out of date, and although is all technically true, holds some bad practices and information.
Instead, if you want to see a list of Functions, check out [HERE](https://tehflamintaco.github.io/Reverse-Programmer-Notation/CommandList.html)