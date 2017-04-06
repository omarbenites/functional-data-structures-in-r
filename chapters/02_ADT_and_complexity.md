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

If we define abstract data structures by the operations they provide, it is natural to represent them in R by a set of generic functions. In this book, I will use the S3 object system for this.^[If you are unfamiliar with generic functions and the S3 system, you can check out my *Object-oriented Programming in R* book [@mailund2017oop] where I explain all this.]

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

Another rule of thumb for interfaces that I will stick to in this book, with one exception, is that I will always have my functions take the data structure as the first argument. This isn't something absolutely necessary, but it fits the convention for generic functions, so it makes it easier to work with abstract interfaces, and even when a function is not abstract---when I need some helper functions---remembering that the first argument is always the data structure just makes it easier to write my code. The one exception to this rule is the construction of linked lists, where tradition is to have a construction function, `cons`, that takes an element as its first argument and a list as its second argument and construct a new list where the element is put at the head of the list. This construction is too much of a tradition for me to mess with, and I won't write a generic function of it, so it doesn't come into conflict with how we handle polymorphism.

Other than that, there isn't much more language mechanics to creating abstract data structures. All operations we define for an abstract data structure have some intended semantics to them, but we cannot enforce this through the language; we just have to make sure that the operations we implement actually do what they are supposed to do.

## Implementing concrete data structures in R

When it comes to concrete implementations of data structures, there are a few techniques we need to translate the data structure designs into R code. In particular, we need to be able to represent what is essentially pointers, and we need to be able to represent empty data structures. Different programming languages will have different approaches to these two issues. Some allow the definition of recursive data types that naturally handle empty data structures and pointers, others have special values that always represent "empty", some have static type systems to help. We are programming in R, however, so we have to make it work here.

For efficient data structures in functional programming, we need recursive data types, which essentially boils down to representing pointers. R doesn't have pointers, so we need a workaround. That workaround is using lists to define data structures and use named elements in lists as our pointers.

Consider one of the simplest data structures known to man: the linked list. If you are not familiar with linked lists, you can return to this section after reading the next chapter, where we will consider these in some detail, but in short, linked lists consist of a "head"---an element we store in the list---and a "tail"---another, one element shorter, list. It is a recursive definition that we can write like this:

```
LIST = EMPTY | CONS(HEAD, LIST)
```

Here `EMPTY` is a special symbol representing the, you guessed it, empty list, and `CONS`---a traditional name for this, from the Lisp programming language---a symbol that construct a list from a `HEAD` element and another `LIST`. The definition allows lists to be infinitely long, but of course in practise a list will eventually end up at `EMPTY`.

We can construct linked lists in R using R's built in `list` data structure. That structure is *not* a linked list, it is a fixed size collection of elements, possibly named. We exploit named elements to build pointers. We can implement the `CONS` construction like this:

```{r}
linked_list_cons <- function(head, tail) {
  structure(list(head = head, tail = tail), 
            class = "linked_list_set")
}
```

We simply construct a `list` with two elements, `head` and `tail`. These will be references to other objects---`head` to the element we store in the list and `tail` to the rest of the list---so we are effectively using them as pointers. We then add a class to the list to make linked lists work as an implementation of an abstract data structure.

Using classes and generic functions to implement polymorphic abstract data structures leads us to the second issue we need to deal with in R. We need to be able to represent empty lists. The natural choice for an empty list would be `NULL`, which represent "nothing" for the built in `list` objects, but we can't get polymorphism to work with `NULL`. We cannot give `NULL` a class. We could, of course, still work with `NULL` as the empty list and just have classes for non-empty lists, but this classes with our desire to have the empty data structures being the one point where we decide concrete data structures instead of just accessing them through an abstract interface. If we can't give empty data structures a type, we would need to use concrete update functions instead. That could make switching between different implementations cumbersome. We really *do* want to have empty data structures with classes.

The trick is to use a sentinel object to represent empty structures. Sentinel objects have the same structure as non-empty data structure objects---which has the added benefit of making some implementations easier to write---but they are recognised as representing "empty". We construct a sentinel as we would any other object, but we remember it for future reference. When we construct an empty data structure, we always return the same sentinel object, and we have a function for checking emptiness that simply checks if its input is identical to the sentinel object. For linked lists, this sentinel trick would look like this:

```{r}
linked_list_nil <- linked_list_cons(NA, NULL)
empty_linked_list_set <- function() linked_list_nil
is_empty.linked_list_set <- function(x) 
  identical(x, linked_list_nil)
```

The `is_empty` function is a generic function that we will use for all data structures.

## Asymptotic running time

While the operations we define in the interface of an abstract data type determines how we can use these in our programs, the *efficiency* of our programs depends on how efficiency the data structure operations are. Because of this, we often consider the time efficiency part of the interface of a data structure---if not part of the *abstract* data structure, we very much care about it when we have to pick concrete implementations of data structures for our algorithms.

When it comes to algorithmic performance, the end goal is always to reduce wall time---the actual time we have to wait for a program to finish. This, however, depends on many factors that cannot necessarily know about when we design our algorithms. The computer the code will run on might not be available to us when we develop our software, and both its memory and CPU capabilities are likely to greatly affect the running time. The running time is also likely to depend intimately on the actual data we will apply the algorithm to. If we want to know exactly how long it will take to analyse a certain set of data, we have to run the algorithm on this data. Once we have done this, we know exactly how long it took to analyse the data, but by then it is too late to explore different solutions to maybe do the analysis faster.

Because we cannot practically evaluate the efficiency of our algorithms and data structures by measuring the running time on the actual data we want to analyse, we use different techniques to evaluate the quality of different possible solutions to our problems.

Once such technique is the use of *asymptotic complexity*, also know as "big-O" notation. Simply put, we abstract away some details of the actual running time of different algorithms or data structure operations and classify their runtime complexity according to upper bounds known up to a constant.

First, we reduce our data to its size. We might have a set with $n$ elements, or a string of length $n$. While our data structures and algorithms might use very different actual wall time to work on different data of the same size, we care only about the number $n$ and not the details of the data. Of course, data of the same size is not all equal, so when we reduce all our information about it to a single size, we have to be a little careful about what we mean when we talk about algorithmic complexity of a problem. Here, we usually use one of two approaches: we talk about the *worst-case* or the *average/expected* complexity. The worst-case runtime complexity of an algorithm is the longest running time we can expect from it on any data of size $n$. The expected runtime complexity of an algorithm is the mean running time for data of size $n$ assuming some distribution over data.

Second, we do not consider the *actual* running time for data of size $n$---where we would need to know exactly how many operations of different kinds would be executed by an algorithm, and how long each kind of operation takes to execute---we just count the number of operations and consider them equal. This gives us some function of $n$ that tells us how many operations an algorithm or operation will execute, but not how long each operation takes. We don't care about the details when comparing most algorithms because we only care about asymptotic behaviour when doing most of our algorithmic analysis.

By asymptotic behaviour, we mean the behaviour of functions when the input numbers grow large. A function 
#ifdef EPUB
f(n)
#else
$f(n)$
#endif
is an asymptotic  upper bound for another function
#ifdef EPUB
g(n)
#else
$g(n)$
#endif
if there exists some number 
#ifdef EPUB
N
#else
$N$
#endif
such that
#ifdef EPUB
g(n) <= f(n)
#else
$g(n) \\leq f(n)$
#endif
whenever
#ifdef EPUB
n > N.
#else
$n>N$.
#endif
We write this in the so-called "big-O" notation as
#ifdef EPUB
g(n) in O(f(n)) or g(n) = O(f(n))
#else
$g(n) \\in O(f(n))$ or $g(n) = O(f(n))$
#endif
(the choice of notation is a little arbitrary and depends on which textbook or reference you use).

The rational behind using asymptotic complexity is that we can use it to reason about how algorithms will perform when we give them larger data sets. If we need to process data with millions of data points, we might be about to get a feeling for their running time through experiments with tens or hundreds of data points, and we might conclude that one algorithm outperforms another in this range. That, however, does not necessarily reflect how the two algorithms will compare for much larger data. If one algorithm is asymptotically faster than another it *will* eventually outperform the other, we just have to get to the point where $n$ gets large enough.

A third abstraction we often use is to not be too careful with getting the exact number of operations as a function of $n$ right. We just want an upper bound. The big-O notation allows us to say that an algorithm runs in any big-O complexity that is an upper bound for the actual runtime complexity. We want, of course, to get this upper bound as exact as we can, in order to properly evaluate different choices of algorithms, but if we have upper and lower bounds for different algorithms we can still compare them. Even if the bounds are not tight, if we can see that the upper bound of one algorithm is better than the lower bound of another, then we can reason about the asymptotic running time of solutions based on the two.

To see the asymptotic reasoning in action, consider the set implementation we wrote earlier:

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

It represent the set as a vector, and when we add elements to the set we simply concatenate the new element to the front of the existing set. Vectors, in R, are represented as contiguous memory, so when we construct new vectors this way, we need to allocate a block of memory to contain the new vector, copy the first element into the first position, and then copy the entire old vector into the remaining positions of the new vector. So inserting an element into a set of size $n$, with this implementation, will take time 
#ifdef EPUB
O(n)
#else
$O(n)$
#endif
---we need to insert 
#ifdef EPUB
n+1
#else
$n+1$
#endif
set elements into newly allocated blocks of memory. Growing a set from size 0 to size $n$ by repeatedly inserting elements will take time 
#ifdef EPUB
O(n^2^).
#else
$O(n^2)$.
#endif

The membership test, `elem %in% set`, runs through the vector until it either sees the value `elem` or until it reach the end of the vector. The best case would be to see `elem` at the beginning of the vector, but if we consider worst-case complexity, this is another 
#ifdef EPUB
O(n)
#else
$O(n)$
#endif
runtime operation.

As an alternative implementation, consider linked lists. We insert elements in the list using the "cons" operation and we check membership by comparing `elem` with the head of the list. If the two are equal, the set contains the element. If not, we check if the `elem` is found in the rest of the list. In a pure functional language we would use recursion for this search, but here I have just implemented it using a `while` look:

```{r}
insert.linked_list_set <- function(set, elem) {
  linked_list_cons(elem, set)
}

member.linked_list_set <- function(set, elem) {
  while (!is_empty(set)) {
    if (set$head == elem) return(TRUE)
    set <- set$tail
  }
  return(FALSE)
}
```

The `insert` operation in this implementation takes constant time. We create a new list node, set the head and tail in it, but unlike the vector implementation we do not copy anything. So for the liked list, inserting elements is an 
#ifdef EPUB
O(1)
#else
$O(1)$
#endif
operation. The membership check, however, still runs in 
#ifdef EPUB
O(n)
#else
$O(n)$
#endif
since we still do a linear search.

## Experimental evaluation of algorithms 

![Direct comparison of the two set construction implementations.](figures/set-comparison-direct){#fig:set-comparison-direct}

![The two set construction implementations with time divided by input size.](figures/set-comparison-div-n){#fig:set-comparison-div-n}

![The two set construction implementations with time divided by input size squared.](figures/set-comparison-div-n-squared){#fig:set-comparison-div-n-squared}