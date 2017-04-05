# Abstract data structures

Before we get started with the actual data structures, we need to get some terminology and notation in place. We need to agree on what an abstract data structure is---in contrast to a concrete one---and we need to agree on how to reason about complexity, in particular runtime complexity, in an abstract way.

If you are at all familiar with algorithms and data structures, you can skim quickly through this chapter. There won't be any theory you are not already familiar with. Do skim through it, though, just to make sure we agree on the notation I will use in the remainder of the book.

If you are not familiar with the material in this chapter, I urge you to find a text book on algorithms that cover this and read beyond this book. The material I cover in this chapter should suffice for the theory we will need in this book, but there is a lot more to data structures and complexity than I can possibly cover in a single chapter. Most good textbooks on algorithms will teach you a lot more, so if you find this book at all interesting, you should not find any difficulties in continuing your studies.

## Structure on data

As the name implies, data structures have something to do with structured data. By data we can just think of elements from some arbitrary set. There might be some more to data points, and when there is we keep that in mind and probably want to exploit that somehow, but in the most general terms we just have some large set of possible data points. Whenever we work with data, we imagine that we have stored some subset of data points that we work on.

So, a simple example of working with data would be imagining we have this large set of possible values---say all possible names of students at this university---and I am interested in a subset---say the students taking one of my classes. A class would be a subset of students, and I could represent it as the subset of student names. When I get an email from a student, I might be interested in figuring out if it is one of *my* students, and in that case, in which class. So, already we have some structure on the data. Different classes are different subsets of student names. We also have an operation we would like to be able to do on these classes: checking membership.

There might be some inherent structure to the data we work with. That could be properties such as lexicographical orders on names---it enables us to sort student names, for example. Other structure, we add on top of this. We add structure by defining classes as subsets of student names. There is even a third level of structure: how we represent the classes on our computer.

The first level of structure---that inherent in the data we work with---is not something we have much control over. We might be able to exploit it in various ways, but otherwise it is just there. When it comes to designing algorithms and data structures, this structure is often simple information; if there is order in our data so we can sort it, for example. Different algorithms and different data structures make various assumptions about the underlying data, but most general algorithms and data structures make very weak assumptions. When we make assumptions in this book, I will make those assumptions explicit.

The second level of structure---the structure we add on top of the universe of possible data points---is information in addition to what just exists out there in the wild. It can be as simple as defining classes as subsets of student names. It is structure we add to data for a purpose, of course. We want to manipulate this structure and use it to answer questions while we evaluate our programs. When it comes to algorithmic theory, what we are mainly interested at this level, is which operations are possible on the data. If we represent classes as sets of student names, we are interested in testing membership to a set. To construct the classes, we might also want to be able to add elements to an existing set. That might be all we are interested in, or we might also want to be able to remove elements from a set, get the intersection or union of two sets, or any other operation on sets.

What we can do with data in a program is largely defined by the operations we can do on structured data. It is less important how we implement the operations. That might effect the efficiency of the operations and thus the program, but when it comes to what is possible to program and what is not---or what is easy to program and what is hard, at least---it is the possible operations that are important.

Because it is the operations we can do on data, and now how we represent the data---the third level of structure we have---that  is most important, we distinguish between the possible operations and how they are implemented. We define *abstract data structures* by the operations we can do, and call different implementations of them *concrete data structures*. Abstract data structures are defined by which operations we can do on data; concrete data structures by how we represent the data and implement these operations.


## Abstract data structures in R

If we define abstract data structures by the operations they provide, it is natural to represent them in R by a set of generic functions. In this book, I will use the S3 object system for this.^[If you are unfamiliar with generic functions and the S3 system, I explain all this in my *Object-oriented Programming in R* book [@mailund2017oop].]

Let's say we want a data structure that represents sets and we need two operations on it: we want to be able to insert elements into the set, and we want to be able to check if an element is found in the set. The generic interface for such a data structure could look like this:

```{r}
insert <- function(set, elem) UseMethod("insert")
member <- function(set, elem) UseMethod("member")
```

Using generic functions, we can replace one implementation with another with little hassle. We just need one place to specify which concrete implementation we will use for an object we will otherwise only access through the abstract interface. Each implementation we write will have one function for constructing an empty data structure. This empty structure sets the class for the concrete implementation, and from here on we can access the data structure through generic functions. We can write a simple list-based implementation of the set data structure like this:

```{r}
empty_list_set <- function() {
  structure(c(), class = "list_set")
}

insert.list_set <- function(set, elem) {
  structure(c(elem, set), class = "list_set")
}

member.list_set <- function(set, elem) {
  elem %in% set
}
```

The `empty_list_set` function is how we create our first set of the concrete type. When we insert elements into a set, we also get the right type back, but we shouldn't call `insert.list_set` direction. We should just use `insert` and let the generic function mechanism pick the right implementation. If we make sure to make the only point where we refer to the concrete implementation be the creation of the empty set, then we make it easier to replace one implementation with another.

```{r}
s <- empty_list_set()
member(s, 1)
s <- insert(s, 1)
member(s, 1)
```

When we implement data structures in R, there are a few rules of thumbs we should follow---some more important than others. Using a single "empty data structure" constructor and otherwise generic interfaces is one such rule. It isn't essential, but it does make it easier to work with abstract interfaces.

More important is this rule: keep modifying and querying a data structure as separate functions. Take an operation such as posing the top element of a stack. You might think of this as a function that removes the first element of a stack and then return the element to you. There is nothing wrong with accessing a stack this way in most languages, but in functional languages it is much better to split this into two different operations: one for getting the top element and another for removing it from the stack.

The reason for this is simple: our functions can't have side effects. If a "pop" function takes a stack as argument, it cannot modify this stack. It can give you the top element of the stack, and it can give you a new stack where the top element is removed, but it cannot give you the top element and then modify the stack as a side effect. Whenever we want to modify a data structure, what we have to do in a functional language, is to create a new structure instead. And we need to return this new structure to the caller. Instead of wrapping query answers *and* new (or "modified") data structures in lists so we can return multiple values, it is much easier to keep the two operations separate.

Another rule of thumb for interfaces that I will stick to in this book is that I will always have my functions take the data structure as the first argument. This isn't something absolutely necessary, but it fits the convention for generic functions, so it makes it easier to work with abstract interfaces, and even when a function is not abstract---when I need some helper functions---remembering that the first argument is always the data structure just makes it easier to write my code.

Other than that, there isn't much more language mechanics to creating abstract data structures. All operations we define for an abstract data structure have some intended semantics to them, but we cannot enforce this through the language; we just have to make sure that the operations we implement actually do what they are supposed to do.


## Asymptotic running time

