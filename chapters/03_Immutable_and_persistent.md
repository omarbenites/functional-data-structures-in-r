# Immutable and persistent data

What prevents us from implementing traditional imperative-language data structures in R is the immutability of data. As a general rule, you can modify environments---so you can assign to variables---but you cannot modify actual data. Whenever R makes it look like you are modifying data, it is lying. When you assign to an element in a vector

```r
x[i] <- v
```

the vector will look modified to you, but behind the curtain R has simply replaced the vector that `x` refers to with a new copy, identical to the old `x` except for element number `i`. It tries to do this efficiently, so it will only copy the vector if there are other references to it, but conceptually, it still makes a copy. 

Now, you could reasonably argue that there is little difference between actually modifying data and simply having the illusion of modifying data, and you would be right, except that the illusion is only skin deep. Since R creates the illusion by making copies of data and assigning the copies to variables in the local environment, it doesn't affect other references to the original data. Data you pass to a function as a parameter will be referenced by a local function variable. If we "modify" such data, we are modifying the local function environment---the caller of the function has a different reference to the same data, and that reference is to the original data that will not be affected by what we do with the local function environment in any way. R is not entirely side-effect free, as a programming language, but side effects are contained to I/O, random number generation, and affecting variable-value bindings in environments. Modifying actual data is not something we can do via function side effects.[^sideeffects] If we want to update a data structure, we have to do what R does when we try to modify data: we need to build a *new* data structure, looking like the one we wanted to change the old one into. Functions that should update data structures need to construct new versions and return them to the caller.

[^sideeffects]: Strictly speaking, we *can* create side effects that affect data structures, we just have to modify environments. The reference class system, R6, emulate objects with mutable state by modifying environments, and we can do the same via closures. When we get to [Chapter @sec:sets-and-search-trees], where we will implement splay-trees, we will need to introduce side effects of member queries, and there we will use this trick. Unless we represent all data structures by collections of environments, however, the trick only gets os so far. We still need to build data structures without modifying data; we just get to remember the result in an environment we constructed for this purpose.

## Persistent data structures

