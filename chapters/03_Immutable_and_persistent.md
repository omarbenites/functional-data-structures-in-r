# Immutable and persistent data

What prevents us from implementing traditional imperative-language data structures in R is the immutability of data. As a general rule, you can modify environments---so you can assign to variables---but you cannot modify actual data. Whenever R makes it look like you are modifying data, it is lying. When you assign to an element in a vector

```r
x[i] <- v
```

the vector will look modified to you, but behind the curtain R has simply replaced the vector that `x` refers to with a new copy, identical to the old `x` except for element number `i`. It tries to do this efficiently, so it will only copy the vector if there are other references to it, but conceptually, it still makes a copy. 

Now, you could reasonably argue that there is little difference between actually modifying data and simply having the illusion of modifying data, and you would be right, except that the illusion is only skin deep. Since R creates the illusion by making copies of data and assigning the copies to variables in the local environment, it doesn't affect other references to the original data. Data you pass to a function as a parameter will be referenced by a local function variable. If we "modify" such data, we are modifying the local function environment---the caller of the function has a different reference to the same data, and that reference is to the original data that will not be affected by what we do with the local function environment in any way. R is not entirely side-effect free, as a programming language, but side effects are contained to I/O, random number generation, and affecting variable-value bindings in environments. Modifying actual data is not something we can do via function side effects.[^sideeffects] If we want to update a data structure, we have to do what R does when we try to modify data: we need to build a *new* data structure, looking like the one we wanted to change the old one into. Functions that should update data structures need to construct new versions and return them to the caller.

[^sideeffects]: Strictly speaking, we *can* create side effects that affect data structures, we just have to modify environments. The reference class system, R6, emulate objects with mutable state by modifying environments, and we can do the same via closures. When we get to [Chapter @sec:sets-and-search-trees], where we will implement splay-trees, we will need to introduce side effects of member queries, and there we will use this trick. Unless we represent all data structures by collections of environments, however, the trick only gets os so far. We still need to build data structures without modifying data; we just get to remember the result in an environment we constructed for this purpose.

## Persistent data structures

Since we cannot modify data, we might as well make a virtue out of necessity. What we get out of immutable data is persistent data structures, that is data structures that retain earlier versions of themselves. Not all types of data structures have persistent versions of themselves, and some persistent data structures can be less efficient than their non-persistent, or ephemeral, counterparts, but constructing persistent data structures is an active area of research so there are data structures enough to pick from when you need one.

To see what I mean by data structures being persistent in R, we look at the simple linked list again. I've defined it below, using slightly shorter names than earlier now that we don't need to remind ourselves that it is a linked list, and I'm using the sentinel trick to create the "empty" list.

```r
is_empty <- function(x) UseMethod("is_empty")

list_cons <- function(elem, lst)
  structure(list(item = elem, tail = lst), class = "linked_list")

list_nil <- list_cons(NA, NULL)
is_empty.linked_list <- function(x) identical(x, list_nil)
empty_list <- function() list_nil

list_head <- function(lst) lst$item
list_tail <- function(lst) lst$tail
```

With these definitions, we can create three lists like this:

```r
x <- list_cons(2, list_cond(1, empty_list()))
y <- list_cons(3, x)
z <- list_cons(4, empty_list())
```

The lists will be represented in memory as shown in [@fig:linked-lists-construction-1]. In the figure I have shown the content of the lists, the head of each, in the white boxes and the tail pointer as a grey box and an error. I have explicitly shown the empty list sentinel in this figure, but in future figures I will simply leave it out. The variables, `x`, `y`, and `z` are shown as pointers to the lists. For `x` and `z` , the lists were created by updating the empty list; for `y` , the list was created by updating `x`. But as we can clearly see, the updated lists are still there. We just need to keep a pointer to them to get them back. That is the essence of persistent data structures and how we need to work with data structures in R.

![Memory layout of linked lists.](figures/linked-lists-construction-1){#fig:linked-lists-construction-1}

## List functions

When we implemented a set through linked lists we saw how to add and search in a list. To get more of a feeling for working with immutable data structures we will try to implement a few more functions manipulating lists. We can start simply by writing a function for reversing a list. This is slightly more complicated than just searching in a list because we will have to construct the reversed list from the wrong end, so to speak. We need to first construct the list that contains the last element of the input list and the empty list. Then we need to put the second last elements at the head of this list, and so on.

When writing a function that operates on persistent data, I always find it easiest to think in terms of recursion. It might not be immediately obvious how to reverse a list as a recursive function, though. If we recurse all the way down to the end of the list, we get hold of the first element we should have in the reversed list, but how do we then fit that into the list we construct going up in the recursion again? There is no simple way to do this. We can, however, use the trick of bring an accumulator with is in the recursive calls and construct the reversed list in this. If you are not familiar with accumulators in recursive functions, I cover it in some detail in my book on functional programming in R [@mailund2017functional], but you can probably follow the idea in the code below. The idea is that the variable `acc` contains the reversed list we have constructed so far. When we get to the end of the recursion, we have the entire reversed list in `acc` so we can just return it. Otherwise, we can recurse on the remaining list but put the head element at the top of the accumulator. With a recursive helper function, the list reversal can look like this:

```r
list_reverse_helper <- function(lst, acc) {
  if (is_empty(lst)) acc
  else list_reverse_helper(list_tail(lst),
                           list_cons(list_head(lst), acc))
}
list_reverse_rec <- function(lst) 
  list_reverse_helper(lst, empty_list())
```

The running time of this function is linear---we need to run through the entire original list, but each operation we do when we construct the new list takes constant time.

I have shown the iterations for reversing a list of length three in [@fig:list-reversal]. In this figure I have not shown the sentinel empty string---I just show the empty string as a pointer to nothing---but you will see how the variable `lst` refers to different positions in the original list as we recurse, while the original list doesn't change at all, while we build a new list pointed to by `acc`.

![Iterations in the recursive list reversal.](figures/list-reversal){#fig:list-reversal}

In a pure functional programming language, this would probably be the best approach to reversing a list. The function uses tail recursion (again, you can read about that in my other book [@mailund2017functional]), so it is essentially a loop we have written. Unfortunately, R does *not* implement tail recursion, so we have a potential problem. If we have a very long list, we can run out of stack space before we finish reversing it. We can, however, almost automatically translate tail recursive functions into loops, and a loop version for reversing a list would then look like this:

```r
list_reverse_loop <- function(lst) {
  acc <- empty_list()
  while (!is_empty(lst)) {
    acc <- list_cons(list_head(lst), acc)
    lst <- list_tail(lst)
  }
  acc
}
```

If the lists are short, there is no immediate benefit in using one solution over the other. There is some overhead in function calls, but there is also some overhead in loops, and the two solutions work equally well for short lists, see [@fig:list-reverse-comparison]. Whenever I can get away with it, I prefer recursive solutions---I find them easier to implement and simpler to understand---but the loop version will be able to deal with much longer lists than the recursive one.

![Looping versus recursive reversal of lists.](figures/list-reverse-comparison){#fig:list-reverse-comparison}


