# Bags, stacks, and queues {#sec:bags-stacks-and-queues}

In this chapter we start building data structures more complex than simple linked lists and unbalanced trees, but still relatively simple compared to those in future chapters. We will consider three abstract data structures: the bag, the list, and the queue. The bag is just a set, but one where we don't value membership queries high enough to make that operation efficient---we just want to be able to construct collections of elements that we can efficiently traverse later. The stack is a last-in-first-out collection of elements, where we can efficiently extract the last element we added to the stack. Finally, the queue is a first-in-first-out collection, where we can efficiently get at the first element we inserted into the queue.

The abstract data type operations we want to have for the three data structures are, for bags

```r
is_empty <- function(x) UseMethod("is_empty")
insert <- function(x, elm) UseMethod("insert")
```

and sometimes

```r
merge <- function(x, y) UseMethod("merge")
```

where `is_empty` is the emptiness check we have used before, `insert` adds a single element to a bag, and `merge` combines two bags, like taking the union of two sets.

For stacks, we want the operations

```r
is_empty <- function(x) UseMethod("is_empty")
push <- function(x, elm) UseMethod("push")
pop <- function(x) UseMethod("pop")
top <- function(x) UseMethod("top")
```

where `push` adds an element to the top of the stack, `pop` removes the top element, and `top` returns the top element.

Finally, for queues, we want the following operations:

```r
is_empty <- function(x) UseMethod("is_empty")
enqueue <- function(x, elm) UseMethod("enqueue")
front <- function(x) UseMethod("front")
dequeue <- function(x) UseMethod("dequeu")
```

Here, `enqueue` inserts an element in the back of the queue, `front` returns the element at the front of the queue, and `dequeue` removes the element at the front of the queue.

## Bags

Bags are probably the simplest data structures we can imagine. They are just collections of elements. We can easily implement them using lists, where we already know how to insert elements in constant time and how to traverse the elements in a list. The `merge` operations, however, is a linear time function when lists are immutable.

Let us consider the list solution to bags. To work with a list version of bags, we need to be able to create an empty bag and test for emptiness. We can do this just as we did for creating lists:

```r
bag_cons <- function(elem, lst)
  structure(list(item = elem, tail = lst), 
            class = c("list_bag", "linked_list"))

bag_nil <- bag_cons(NA, NULL)
is_empty.list_bag <- function(x) identical(x, bag_nil)
empty_list_bag <- function() bag_nil
```

The only thing worth noticing here is that I made the class of the elements in the bag-list both `"list_bag"` and `"linked_lists"`. This allows me to treat my bags as if they were lists, because in every sense of the word they actually are. We have to be a little careful with that, though, because if we call functions that returns lists on a bag, the resulting type will be a list and not a bag. Fine for queries, but less fine for modifying bags. In any case, we only have two operations we need to implement for updating bags, so we can handle that.

The simplest operation is `insert` where we can just put a new element at the front of the list:

```r
insert.list_bag <- function(x, elm) bag_cons(elm, x)
```

The merge operation is more problematic. If we know that the two bags we are merging contains disjoint sets of elements, we can implement it by just concatenating the corresponding lists. We can reuse the `list_concatenate` function from earlier, but we need to remember to set the class of the result. This works fine as long as we never take the tail of the result---that would give us a list and not a bag because of the way `list_concatenate` works, but then, taking the tail of a bag is not really part of the interface to bags anyway. So we could simply implement `merge` like this:

```r
merge.list_bag <- function(x, y) {
  result <- list_concatenate(x, y)
  class(result) <- c("list_bag", "linked_list")
  result
}
```

Since list concatenation is a linear time operation, bag merge is as well. We can, however, improve on this by using a tree to hold bags. We can exploit that binary trees with 
#ifdef EPUB
n
#else
$n$
#endif
leaves have
#ifdef EPUB
n-1
#else
$n-1$
#endif
inner nodes, so if we put all our values in leaves of a binary tree, we can traverse it in linear time.

We can construct a binary tree bag with some boilerplate code for the empty tree like this:

```r
bag_node <- function(elem, left, right)
  structure(list(item = elem, left = left, right = right),
            class = "tree_bag")

tree_bag_nil <- bag_node(NA, NULL, NULL)
is_empty.tree_bag <- function(x) identical(x, tree_bag_nil)
empty_tree_bag <- function() tree_bag_nil
```

Then, for inserting a new element, we create a leaf. If we try to insert the element into an empty tree we should just return the leaf---otherwise we end up with non-binary nodes and then the running time goes out the window---but otherwise we just put the leaf to the left of a new root and the bag at the right. There is no need to keep the tree balanced since we don't plan to search in it or delete elements from it; for bags we just want to be able to traverse all the elements.

```r
insert.tree_bag <- function(x, elm) {
  element_leaf <- bag_node(elm, empty_tree_bag(), empty_tree_bag())
  if (is_empty(x)) element_leaf
  else bag_node(NA, element_leaf, x)
}
```

[@Fig:bag_cons] illustrates a tree bag and the insert operation. On the left is shown a bag containing the elements 1, 5, and 7, created, with the operations

```r
x <- insert(insert(insert(empty_tree_bag(), 7, 5, 1)))
```

On the right, we see the situation after running

```r
insert(x, 4)
```

The new element is added as the left tree of a new root and the original `x` bag is the right subtree of the new root.

![Inserting elements in a tree bag.](figures/bag_cons){#fig:bag_cons}

Merging can now be done in constant time. We need to be careful not to create inner nodes with empty subtrees, but otherwise we can just create a node that has the two bags we merge as its left and right subtrees:

```r
merge.tree_bag <- function(x, y) {
  if (is_empty(x)) return(y)
  if (is_empty(y)) return(x)
  bag_node(NA, x, y)
}
```

[@Fig:bag-merge] illustrates a merge between two non-empty bags, `x` and `y`.

![Merging two tree bags.](figures/bag-merge){#fig:bag-merge}

Traversing the elements in the bag can be done by recursing over the tree. As an example, we can write a function that extracts all the leaves as a linked list. That would look like this:

```r
is_leaf <- function(x) {
  is_empty(x$left) && is_empty(x$right)
}
bag_to_list <- function(x, acc = empty_list()) {
  if (is_leaf(x)) list_cons(x$item, acc)
  else bag_to_list(x$right, bag_to_list(x$left, acc))
}
```

This implementation of `merge` also assumes that the bags we merge are disjoint sets. If they are not, we have more work to do. I am not aware of any general efficient solutions to this problem, if we don't want duplications, but two 
#ifdef EPUB
n log(n)
#else
$n\\log(n)$
#endif
algorithms are straightforward: we can sort the bags and merge them---this would take 
#ifdef EPUB
n log(n)
#else
$n\\log(n)$
#endif
for the sorting and then linear time for merging them, or we could simply put all the bag elements into a search tree and extract them from there. We can sort elements in this complexity using the heap data structure, see [chapter @sec:heaps], and we can construct and extract the unique elements in a search tree, see [chapter @sec:sets-and-search-trees].

## Stacks

Stacks are, if possible, even easier to implement using linked lists. Essentially, we just need to rename some of the functions; all the operations are readily available as list functions.

We need some boiler plate code again to get the type right for empty stacks:

```r
stack_cons <- function(elem, lst)
  structure(list(item = elem, tail = lst),
            class = c("stack", "linked_list"))

stack_nil <- stack_cons(NA, NULL)
is_empty.stack <- function(x) identical(x, stack_nil)
empty_stack <- function() stack_nil
```

After that, we can just reuse list functions:

```r
push.stack <- function(x, elm) stack_cons(elm, x)
pop.stack <- function(x) list_tail(x)
top.stack <- function(x) list_head(x)
```

That was pretty easy. Queues, on the other hand, those will require a bit more work...

## Queues

Stacks are easy to implement because we can push elements onto the head of a list and when we need to get them again, they are right there at the head. Queues, on the other hand, have a first-in-first-out semantics, so when we need to get the element at the beginning of a queue, if we have implemented the queue as a list, it will be at the *end* of the list, not the head of the list. A straightforward implements would therefore let us enqueue elements in constant time but get the front element and dequeue it in linear time.

There is a trick, however, for getting an amortised constant time operations queue. This means that the worst case time usage for each individual operations will not be constant time, but whenever we have done
#ifdef EPUB
n
#else
$n$
#endif
operations in total, we have spent time in
#ifdef EPUB
O(n).
#else
$O(n)$.
#endif
The trick is this: we keep track of two lists, one that represents the front of the queue and one that represents the back of the queue. The front of the queue is ordered such that we can get the front as the head of this list, and the back of the queue is ordered such that we can enqueue elements by putting them at the head of that list. From time to time we will have to move elements from the back list to the front lists; this we do whenever we try to get the front of the queue or try to dequeue from the queue and the front list is empty.

This means that some `front` or `dequeue` operations will take linear time instead of constant time, of course. Whenever we need to move elements from the back of the queue to the front, we need to copy and reverse the back of the queue list. On average, however, a linear number of operations take a linear amount of time. To see this, imagine that each `enqueue` operation actually takes twice as long as it really does. When we `enqueue` an element we spend constant time, so doubling the time is still constant time, but you can think of this doubling as paying for enqueueing an element *and* moving it from the back to the front. The first half of the time cost is payed right away when we enqueue the element, the second half you can think of as being put in a time bank. We are saving up time that we can later use to move elements from the back of the queue to the front. Because we put time in the bank whenever we add an element to the back of the queue, we always have enough in reserve to move the elements to the front of the queue later. Not all operations are constant time, but the cost of the operations are amortised over a sequence of operations, so on average they are.

[@Fig:queue-amortized-linear-bound] illustrates the amortised time complexity. The solid line shows the number of list operations we have performed while doing a series of queue operations. We count one operation per `enqueue` function call and one operation per `front` and `dequeue` when we only modify the front list. When we move elements from the back list to the front list, we count the number of elements we move as well. The dashed line shows the time usage plus the number of operations we have in the bank. The line thus shows 
#ifdef EPUB
2 e + f + d,
#else
$2e+f+d$,
#endif
where
#ifdef EPUB
e
#else
$e$
#endif
is the number of `enqueue` operations, 
#ifdef EPUB
f
#else
$f$
#endif
is the number of `front` operations, and
#ifdef EPUB
d
#else
$d$
#endif
is the number of `dequeue` operations. When we `enqueue`, we put value in the bank, that then pays for the expensive `front` or `dequeue` operations further down the line. A linear upper bound for the entire running time is simply two times the number of operations---shown as the dotted line.

![Amortised linear bound on queue operations.](figures/queue-amortized-linear-bound){#fig:queue-amortized-linear-bound}

So, we can implement a queue as two lists. A problem presents itself now, though. Updating and querying the data structure are not completely separate operations any longer. If we try to get the `front` element of a queue, we might have to update the queue; if the front list is empty and the back list is not, we need to move all the elements from the back list to the front list before we can get the front element. This is something we will generally want to avoid; if querying a data structure also modifies it, we will need to return both the result of queries and the updated data structure on these operations, which breaks the clean interface and makes for some ugly code. It is, however, not unusual that we have persistent data structures with good amortised time complexity, if not worst case complexity, that relies on modifying them when we query them, so implementing this queue solution gives me the opportunity to show you a general trick for handling queries that modify data structures in R: using environments that we *can* modify. After that, I will show you a simpler solution for queues---we can actually extend the representation of queues a tiny bit to avoid the problem, but this isn't always possible, so it is worth knowing the general trick.

What we want, essentially, is to have `front` have the side effect of moving elements from the back of the queue and to the front in case the front list is empty. With the `dequeue` operation, we don't have a problem; that operation returns an updated queue in any case. But `front` should only return the front of the list---any new queue it might need to construct isn't returned. If it was entirely impossible for R functions to have side effects, that would be the end of this strategy, but R is not a pure functional language and some side effects are possible. We cannot modify data, but we can modify environments. We can change the binding of variables to data values. We can construct a queue that we can query and modify at the same time, if we use an environment to hold values we need to update. We can do this explicitly using an environment object, or implicitly using closures. Of course, both environment based solutions will not give us a persistent data structure. Because we do introduce side effects, we get a more traditional ephemeral data structure---but at the end of the chapter you will see how we get a persistent queue, so no worries.

### Side effects through environments

Since we can modify environments, we can just make an environment object and use it as our queue. We can construct it like this, set the class so we can treat it as both an environment and a queue, and store the two lists in it:

```r
queue_environment <- function(front, back) {
  e <- new.env(parent = emptyenv())
  e$front <- front
  e$back <- back
  class(e) <- c("env_queue", "environment")
  e
}
```

Here, we set the parent of the environment to the empty environment. If we didn't, the default would be to take the local closure as the parent. This wouldn't hurt us in this particular instance, but there is no need to chain the environment, so we don't.

Obviously, this isn't a pure functional data structure nor a persistent data structure, but it gets the job done.

We don't need a sentinel object to represent the empty queue with this representation. We can construct a queue with two empty lists and we can check if the two lists in the queue are empty:

```r
empty_env_queue <- function()
  queue_environment(empty_list(), empty_list())

is_empty.env_queue <- function(x)
  is_empty(x$front) && is_empty(x$back)
```

The operations on queues are relatively straightforward. When we add an element to the back of a queue, we just put it at the front of the back list:

```r
enqueue.env_queue <- function(x, elm) {
  x$back <- list_cons(elm, x$back)
  x
}
```

If the front list is empty, we need to replace it with the reversed back list, and set the back list to empty, but otherwise we just take the head of the front list:

```r
front.env_queue <- function(x) {
  if (is_empty(x$front)) {
    x$front <- list_reverse(x$back)
    x$back <- empty_list()
  }
  list_head(x$front)
}
```

Finally, to remove an element from he front of the queue, we just replace the front with the tail of the front list. If the front list is empty, though, we need to update it first, just as for the `front` function:

```r
dequeue.env_queue <- function(x) {
  if (is_empty(x$front)) {
    x$front <- list_reverse(x$back)
    x$back <- empty_list()
  }
  x$front <- list_tail(x$front)
  x
}
```

Strictly speaking, we didn't have to return the updated queue in the `enqueue` and `dequeue` functions, since we are updating the environment that represents it directly. We should do it anyway, though, if we want to implement the interface we specified for the abstract data type. If we have those two functions return an updated queue, even when we are not implementing an persistent data structure, we can later replace the implementation with one that doesn't modify data but truly implement queues as persistent structures.

### Side effects through closures

There is an alternative way of implementing a queue as an environment that does so with an implicit rather than an explicit environment. I don't personally find this approach as readable as using an explicit environment in this particular instance---but I have used the trick in a few situations where I do think it improves readability, and I have seen it used in the wild a few places, so I thought I might as well show it to you.

If we create closures---functions defined inside other functions---we get an implicit enclosing environment that we can use to update data. We can use such a closure to get a reference to a queue that we can update. We can create a local environment  that contains the front and the back lists and update these in closures, but just to show an alternative, I will instead keep a single queue object in the closure environments and update it by replacing it with updated queues when I need to. The queue object will look like this:

```r
queue <- function(front, back)
  list(front = front, back = back)
```

The closures will now work as this: I create a number of functions inside another function---a function that has a local variable that refers to a queue---and return the functions in a list. When functions need to modify the queue, they assign new versions of the queue to the variable in the enclosing environment using the `` `<<-` `` assignment operator. All the closures refer to the same variable, so they all see the updated version when they need to access the queue. I collect all the closures in a list that I return from the closure-creating function, with a class set to make it work with generic functions. The full implementation looks like this:

```r
queue_closure <- function() {
  q <- queue(empty_list(), empty_list())

  queue_is_empty <- function()
    is_empty(q$front) && is_empty(q$back)

  enqueue <- function(elm) {
    q <<- queue(q$front, list_cons(elm, q$back))
  }

  front <- function() {
    if (is_empty(q$front)) {
      q <<- queue(list_reverse(q$back), empty_list())
    }
    list_head(q$front)
  }

  dequeue <- function() {
    if (is_empty(q$front)) {
      q <<- queue(list_tail(list_reverse(q$back)), empty_list())
    } else {
      q <<- queue(list_tail(q$front), q$back)
  }

  structure(list(is_empty = queue_is_empty,
                 enqueue = enqueue,
                 front = front,
                 dequeue = dequeue),
            class = "closure_queue")
}
```

The basic access and modification of the queue are essentially the same as for the implementation with the explicit environment except that I need to use a different name for the function that tests if the queue is empty. If I called that function `is_empty`, I would be shadowing the global generic function and then I couldn't use it on the lists I use to implement the queue. In the list that I return, I can still call it `is_empty`, though.

When I need to create an empty queue, I just call the closure:

```r
empty_queue <- function() queue_closure()
```

Now, to implement the generic functions for the queue interface, we just need to dispatch calls to the appropriate closures:

```r
is_empty.closure_queue <- function(x) x$queue_is_empty()
enqueue.closure_queue <- function(x, elm) {
  x$enqueue(elm)
  x
}
front.closure_queue <- function(x) x$front()
dequeue.closure_queue <- function(x) {
  x$dequeue()
  x
}
```

We still need to return the modified queue, i.e. the list of closures, to implement the abstract interface, but other than that, we just call the closures to get the queue modified when needed.

As I mentioned, I find the implementation using an explicit environment simpler in this particular case, but the two implementations are equivalent and you can use either depending on your taste.

### A purely functional queue

The only reason we couldn't make the queue data structure purely functional was that the accessor function `front` needed to get to the last element in the back list, which we cannot do in amortised constant time unless we modify the queue when the front list is empty. Well, it is only one element we need access to in special cases of calls to `front`, so we can make a purely functional---truly persistent---queue if we just explicitly remember that value in a way where we can get to it in constant time. We can make an extended version of the queue that contains the two lists, front and back, *and* the element we need to return if we call `front` on a queue when the front list is empty:

```r
queue_extended <- function(x, front, back)
  structure(list(x = x, front = front, back = back),
            class = "extended_queue")
```

With this representation, we will require that we always satisfy the invariant that `x` refers to the last element in the `back` list when the list is not empty. If `back` is empty, we don't care what `x` is.

We don't need a sentinel object for this implementation of queues; testing whether a queue is empty can still be done just by testing if the two lists are empty. We can create an empty queue from two empty lists, and if they are both empty, we don't need to have any particular value for the last element of the back list---we already know it is empty so we shouldn't try to get to the front of the queue in either case.

```r
empty_extended_queue <- function()
  queue_extended(NA, empty_list(), empty_list())
  
is_empty.extended_queue <- function(x)
  is_empty(x$front) && is_empty(x$back)
```

When we add an element to the back of a queue, we now need to remember the value of the element if it is going to end up at the back of the back list. It will, if the back queue is empty, so if `back` is empty, we remember the value we add in `x`; otherwise, we keep remembering the value we already stored in the queue:

```r
enqueue.extended_queue <- function(x, elm)
  queue_extended(ifelse(is_empty(x$back), elm, x$x),
                 x$front, list_cons(elm, x$back))
```

When we need the front element of the queue, we are in one of two situations: either the `front` list is empty, in which case we need to return the last element in `back`, which we have stored in `x`. If `front` is not empty, we can just return the head of that list:

```r
front.extended_queue <- function(x) {
  if (is_empty(x$front)) x$x
  else list_head(x$front)
}
```

When we remove the front element of the queue, we should just remove the front element of `front`, except when `front` is empty. Then we should reverse `back` and put it at the front, and when we empty `back` then `x` doesn't have any particular meaning any longer:

```r
dequeue.extended_queue <- function(x) {
  if (is_empty(x$front))
    x <- queue_extended(NA, list_reverse(x$back), empty_list())
  queue_extended(x$x, list_tail(x$front), x$back)
}
```

### Time comparisons

We can compare the time usage of the three queue implementations in practise, see [@fig:queue-comparisons]. The two environment based implementations run in the same wall time but there is an extra overhead in the functional implementation. This is caused by wrapping the newly constructed queues in a new structure each time---on top of wrapping lists in structures whenever we manipulate them.

![Comparison of the running time for constructing and emptying the three implementations of queues.](figures/queue-comparisons){#fig:queue-comparisons}

We could speed up the implementation if we were willing to not wrap the implementation as an abstract data structure---and we could do the same if we didn't represent the lists as objects and just used head and tail pointers---but implementing a functional queue with the amortised complexity to avoid side-effects isn't as useful as it might sound. The amortised complexity we achieve is very good if we treat the queues as ephemeral data structures, but not actually that great for persistent data structures as you might think. The amortised analysis simply doesn't work if we want to use the queue as a persistent data structure.

### Amortised time complexity and persistent data structures

When we work with data structures with amortised complexity, we imagine that some of the cheap operations actually cost a little more than they do, and then we can afford some of the more expensive operations for the "computation" we put in the bank when we invoke the cheap operations. Thinking in terms of the average cost of a sequence of operations, instead of having to make guarantees about each individual operation, often makes the analysis and construction of data structures simpler, and quite often also faster because we can work with simpler implementations. It is sound reasoning when we consider a sequence of operations where the data structure we update in one operation becomes the input to the next operation. If we want to use the data structures as persistent data, however, the reasoning fall apart.

Imagine that we insert a number of elements in the back of a queue, which now has a full "back" list and an empty "front" list. We have now paid for one reversal of the back list when we do the first dequeuing, but if we treat the queue as a persistent data structure, we could end up dequeuing from the same instance several times. By considering the insertions into the queue as twice as expensive as they actually are---as we did in the analysis---we can pay for the first dequeuing, reversing the list and all, but it only pays for the *first* reversal of the back list. If the queue is persistent, there is nothing that prevents us from calling a dequeue operation on the same queue several times. Each call to `dequeue` will be an expensive operation, linear in the length of the back list, but the savings we put in the bank when we inserted elements in the queue only pays for the first one. The amortised analysis is really only valid if we treat the structure as ephemeral.

The queue implementations we have seen here are pretty fast if we treat them as ephemeral, but if we want persistent queues with a constant time adding and removing operations, each operation has to be constant time operations. 

### Double-ended queues

A double-ended queue, also known as a "deque", is a queue where you can add and remove elements from both ends of the queue. The operations on a double-ended queue, as an abstract data structure, would be these:

```r
enqueue_front <- function(x, elm) UseMethod("enqueue_front")
enqueue_back <- function(x, elm) UseMethod("enqueue_back")

front <- function(x) UseMethod("front")
back <- function(x) UseMethod("back")

dequeue_front <- function(x) UseMethod("dequeue_front")
dequeue_back <- function(x) UseMethod("dequeue_back")
```

We can implement a double-ended queue using two lists, a front and a back list, just as we did with queues. We can easily add elements to both the front and the back by putting new elements at the head of the two lists. If we want to get the front or back of the elements, or if we want to remove the front or the back element, we can just access the head of the two lists, as long as they are not empty. If they are empty, though, we have to be a little more careful.

The problem with just following the same procedure as we did for queues is that if we reverse the front or back list whenever the other list is empty, we might end up with linear time operations when we switch between removing elements from the front and from the back. This is something we want to avoid, and we can do that with a small modification to the procedure: instead of reversing and moving an entire list, when the other is empty, we only move half the other list. We will end up with the same amortised complexity as for the queues---which means that as long as we implement double-ended queues as ephemeral data structures, we get constant time operations.

The complexity analysis is a little more involved. We can still think of the insertion operations as being slightly more expensive, taking one "computation coin" to execute and then putting one "computation coin" in the bank, but the bank holdings we now have to think of as the difference between the length of the front list and the back list. If you are familiar with amortised analysis, you should think of a potential function that is the absolute difference between the length of the front list and the back list, but to keep it simple here, we will still think in terms of putting computation coins in a bank that we can then use to pay for expensive operations later on. It is just that the coin we put in the bank when we insert an element won't necessarily pay for all the times that individual element gets moved between the lists. The same element might be moved between the lists more than once, which puts that element in debt, but we can recover that debt by using coins that are payed for by other elements.

If we let *f* denote the number of elements in the front list, and *b* denote the number of elements in the back list, then we want the invariant to be that we have abs(*f*-*b*) in the bank to pay for future operations. If we insert an element in the shorter of the two lists, we might think of inserting an extra computation coin in the bank, but we don't really need to, to satisfy the invariant, so it is just extra money we won't need. If we insert an element in the longer list, however, we need to pain an extra coin to pay for the increased difference between the list lengths. That is okay, it is still a constant time operation even if it is twice as expensive as just inserting an element.

If one of the lists is empty, however, and we need to get an element from it, we need to move some elements. The cost of that, we need to take out of the bank. If the invariant is satisfied, though, we have as many coins in the bank as the length of the non-empty list. If we move half the elements in that list to the other list, we spend half the savings we have in the bank, but what remains is still enough to pay for the abs(**f**-**b**) invariant to be true. If the two lists end up being exactly the same length, we only require that there is a non-negative amount of coins in the bank---which will be true if we only spend half the coins there---and if the lists are one off, we need one remaining coin, which again will be true if we only spend half the coins there. So we are good.

So, to implement double-ended queues with a constant time (amortised) operation complexity, we just need to move half the lists when we need to move anything, rather than the entire lists.


To implement double-ended queues, we need two operations: get the first half of a list, and get the second half of a list. 

If we know how many elements are in half the list, we can use these two functions for this:

```r
list_get_n_reversed <- function(lst, n) {
  l <- empty_list()
  while (n > 0) {
    l <- list_cons(list_head(lst), l)
    lst <- list_tail(lst)
    n <- n - 1
  }
  l
}

list_drop_n <- function(lst, n) {
  l <- lst
  while (n > 0) {
    l <- list_tail(l)
    n <- n - 1
  }
  l
}
```

Both functions will do their work in time 
#ifdef EPUB
n
#else
$n$
#endif
so we should be able to move elements from one list to the other in the time we have, if we let *n* be half the length of the list we move elements from.

We can get the list length like this:

```r
list_length <- function(lst) {
  n <- 0
  while (!is_empty(lst)) {
    lst <- lst$tail
    n <- n + 1
  }
  n
}
```

We can then implement the double-ended queue like this:

```r
deque_environment <- function(front, back) {
  e <- new.env(parent = emptyenv())
  e$front <- front
  e$back <- back
  class(e) <- c("env_deque", "environment")
  e
}

empty_env_deque <- function()
  deque_environment(empty_list(), empty_list())

is_empty.env_deque <- function(x)
  is_empty(x$front) && is_empty(x$back)

enqueue_back.env_deque <- function(x, elm) {
  x$back <- list_cons(elm, x$back)
  x
}
enqueue_front.env_deque <- function(x, elm) {
  x$front <- list_cons(elm, x$front)
  x
}

front.env_deque <- function(x) {
  if (is_empty(x$front)) {
    n <- list_length(x$back)
    x$front <- list_get_n_reversed(x$back, ceiling(n))
    x$back <- list_drop_n(x$back, ceiling(n))
  }
  list_head(x$front)
}
back.env_deque <- function(x) {
  if (is_empty(x$back)) {
    n <- list_length(x$front)
    x$back <- list_get_n_reversed(x$front, ceiling(n))
    x$front <- list_drop_n(x$front, ceiling(n))
  }
  list_head(x$back)
}

dequeue_front.env_deque <- function(x) {
  if (is_empty(x$front)) {
    n <- list_length(x$back)
    x$front <- list_get_n_reversed(x$back, ceiling(n))
    x$back <- list_drop_n(x$back, ceiling(n))
  }
  x$front <- list_tail(x$front)
  x
}
dequeue_back.env_deque <- function(x) {
  if (is_empty(x$back)) {
    n <- list_length(x$front)
    x$back <- list_get_n_reversed(x$front, ceiling(n))
    x$front <- list_drop_n(x$front, ceiling(n))
  }
  x$back <- list_tail(x$back)
  x
}
```

If you are a little bit uncomfortable now, you should be. If you are not, I want you to look over the solution we have so far and think about where I might have been cheating you a little.

If you don't see it yet, I will give you a hint: we have half the length of the list we are taking elements from to spend from the bank, but are we using more than that?

Do you see it now? We are okay in pretty much all the operations we are doing, but how do we get the length of the list?

It is very easy to get it *almost* right when you implement data structures, but the slightest errors can hurt the performance, so I left a little trap in this data structure to keep you on your toes. What we have right now is *almost* right, but we do spend a little too much time in reversing half of the lists. We only have coins in the bank for taking half a list, but to get the length of the list, we spend the full list length in coins. To figure out how long a list is, the implementation I showed you before runs through the entire list. That is too much for our analysis to be true. If you take the implementation we have so far and experiment with it to measure the running time you will see this---which is why I encourage you to always test the implementations with measurements and not just rely on analyses. It doesn't matter how careful we are in the design and analysis of a data structure, if we get a slight implementation detail wrong, it all goes out the window---always check if the performance you expect from your analysis is actually correct when measured against wall time.

The solution to this problem is simple enough, though. If we can figure out the lengths of the two lists in constant time, we can also move half of them in the allotted time. The simplest way of knowing the length of the lists when we need it is to simply keep track of it. So we can add the lengths of the lists to the double-ended queue as extra information.

```r
deque_environment <- function(front, back, 
                              front_length, back_length) {
  e <- new.env(parent = emptyenv())
  e$front <- front
  e$back <- back
  e$front_length <- front_length
  e$back_length <- back_length
  class(e) <- c("env_deque", "environment")
  e
}

empty_env_deque <- function()
  deque_environment(empty_list(), empty_list(), 0, 0)
```

The test for emptiness doesn't have to change---there, we just check if the lists are empty, and if we are correct in keeping track of the lengths, we will be correct there as well.

Whenever we add an element to a list, we have to add one to the length bookkeeping as well:

```r
enqueue_back.env_deque <- function(x, elm) {
  x$back <- list_cons(elm, x$back)
  x$back_length <- x$back_length + 1
  x
}
enqueue_front.env_deque <- function(x, elm) {
  x$front <- list_cons(elm, x$front)
  x$front_length <- x$front_length + 1
  x
}
```

Now, when modifying the lists, we need to update the lengths as well. That is used several places, so we can implement to helper functions to keep track of it like this:

```r
move_front_to_back <- function(x) {
  n <- list_length(x$front)
  m <- ceiling(n)
  x$back <- list_get_n_reversed(x$front, m)
  x$front <- list_drop_n(x$front, m)
  x$back_length <- m
  x$front_length <- n - m
}

move_back_to_front <- function(x) {
  n <- list_length(x$back)
  m <- ceiling(n)
  x$front <- list_get_n_reversed(x$back, m)
  x$back <- list_drop_n(x$back, m)
  x$front_length <- m
  x$back_length <- n - m
}
```

Then, we can update the operations like this:

```r
front.env_deque <- function(x) {
  if (is_empty(x$front)) move_back_to_front(x)
  list_head(x$front)
}
back.env_deque <- function(x) {
  if (is_empty(x$back)) move_front_to_back(x)
  list_head(x$back)
}

dequeue_front.env_deque <- function(x) {
  if (is_empty(x$front)) move_back_to_front(x)
  x$front <- list_tail(x$front)
  x
}
dequeue_back.env_deque <- function(x) {
  if (is_empty(x$back)) move_front_to_back(x)
  x$back <- list_tail(x$back)
  x
}
```

Now, we only spend time moving elements linearly in the number of elements we move, and then the amortised analysis invariant is satisfied.


## Lazy queues

It is possible to implement worst-case 
#ifdef EPUB
O(1)
#else
$O(1)$
#endif
operation queue as well as amortised queues by exploiting lazy evaluation. For the rest of this chapter, I will describe an implementation of these following @okasaki_1995.

Because lazy evaluation is not the natural evaluation strategy in R, except for function parameters that *are* lazy evaluated, we have to implement it ourselves. This adds some overhead to the data structure, in the form of extra function evaluations, so this implementation cannot compete with the previous data structures we have seen in terms of speed, but since all operations are in constant time, you *can* use it as a persistent queue.

### Implementing lazy evaluation

Expressions in R are evaluated immediately except for expressions that are parsed as parameters to functions, see @mailund2017functional. This means that an expression such as

```r
1:10000
```

immediately creates a vector of ten thousand elements. However, if we write a function like this:

```r
f <- function(x, y) x
```

where we don't access y, and call it with parameters like these

```r
f(5, 1:10000)
```

the vector expression is never evaluated.

We can thus wrap expressions we don't want to evaluate just yet in thunks, functions that do not take any arguments but evaluate an expression. For example, we could write a function like this:

```{r}
lazy_thunk <- function(expr) function() expr
```

It takes the expression `expr` and returns a thunk that will evaluate it when we call it. It will only evaluate it the first time, though, since R remembers the values of such parameters once they are evaluated. We can see this in the code below:

```{r}
library(microbenchmark)
microbenchmark(lazy_vector <- lazy_thunk(1:100000), times = 1)
microbenchmark(lazy_vector()[1], times = 1)
microbenchmark(lazy_vector()[1], times = 1)
```

The construction of the vector is cheap because the vector expression isn't actually evaluated when we construct it. The first time we access the vector, though, and notice that we need to evaluate `lazy_vector` as a thunk to get to the expression it wraps, we will have to construct the actual vector. This is a relatively expensive operation, but the second time we access it, it is already constructed and we will have a cheap operation.

We have to be a little careful with functions such as `lazy_thunk`. The `expr` parameter will be evaluated when we call the thunk the first time, but it will be evaluated in the calling scope where we constructed the thunk but as it looks when we evaluate the thunk. If it depends on variables that have been modified since we created the thunk, the expression we get might not be the one we want. The function `force` is typically used to alleviate this problem. It forces the evaluation of a parameter so it evaluates to values that matches the expression at the time the thunk is constructed. This won't work here, though---we implement the thunk exactly because we do not want the expression evaluated.

If we are careful with how we use thunks and make sure that we give them expressions where any variables have already been forced, though, we can exploit lazy evaluation of function parameters to implement lazy expressions.

### Lazy lists

Now, let us implement lazy lists to see how we can use lazy evaluation. We are only going to use the lazy lists wrapped in a queue, so I won't construct classes with generic functions, to avoid the overhead we get there and to simplify the implementation. To avoid confusion with the function names we use with the abstract data types, I will use different names for constructing and accessing lists: I will use terminology from lisp-based languages and use `cons` for constructing lists, `car` for getting the head of a list, and `cdr` for getting the tail of a list. The names do not give much of a hint at what the functions do, but are based on [IBM 704 assembly code](https://en.wikipedia.org/wiki/CAR_and_CDR), but they are common in languages based on Lisp, so you are likely to run into them if you study functional programming, so you might as well get used to them.

We will make the following invariant for lazy lists: a list is always a thunk that either returns `NULL`, when the list is empty, or a structure with a `car` and a `cdr` field. We implement construction and access to lists like this:

```{r}
nil <- function() NULL
cons <- function(car, cdr) {
  force(car)
  force(cdr)
  function() list(car = car, cdr = cdr)
}

is_nil <- function(lst) is.null(lst())
car <- function(lst) lst()$car
cdr <- function(lst) lst()$cdr
```

This is very similar to how we have implemented the linked lists we have used so far, except that we do not use polymorphic functions and we use `NULL` for the empty list instead of a sentinel.

We can take any of the functions we have written for linked lists and make them into lazy lists by wrapping what they return in a thunk. Take, for example, list concatenation. Using the functions for lazy lists, the implementation we have would look like this:

```{r}
cat <- function(l1, l2) {
  rev_l1 <- nil
  while (!is_nil(l1)) {
    rev_l1 <- cons(car(l1), rev_l1)
    l1 <- cdr(l1)
  }
  result <- l2
  while (!is_nil(rev_l1)) {
    result <- cons(car(rev_l1), result)
    rev_l1 <- cdr(rev_l1)
  }
  result
}
```

This function simply does what the previous concatenation function did, but with lazy lists. It is not lazy itself, though, it takes linear time to execute and does the reversal right away.

We can experiment with it by constructing some long lists with this helper function:

```{r}
vector_to_list <- function(v) {
  lst <- nil
  for (x in rev(v)) lst <- cons(x, lst)
  lst
}

l1 <- vector_to_list(1:100000)
l2 <- vector_to_list(1:100000)
```

We see that the concatenation operation is slow:

```{r}
microbenchmark(lst <- cat(l1, l2), times = 1)
```

The operation takes more than a second to complete. Accessing the list after we have concatenate `l1` and `l2`, however, is fast:

```{r}
microbenchmark(car(lst), times = 1)
microbenchmark(car(lst), times = 1)
```

These operations run in microseconds, and because we are not delaying any operations we spend the same time both times we call `car` on `lst`.

We can now try slightly modifying `cat` to delay its evaluation by wrapping its return value in a thunk. We need to `force` its parameters to avoid the usual problems with them referring to variables in the calling environment, but we can wrap the concatenation in a thunk after that:^[I will use an explicit function, `lazy_thunk`, to wrap operations in this chapter. You could equally well just return an anonymous function, but you would have to remember to evaluate the body as a function to make it behave as a list. So, instead of returning `lazy_thunk(do_cat(l1,l2))` in the `cat` function we could return `function() do_cat(l1,l2)()`.]

```{r}
cat <- function(l1, l2) {
  do_cat <- function(l1, l2) {
    rev_l1 <- nil
    while (!is_nil(l1)) {
      rev_l1 <- cons(car(l1), rev_l1)
      l1 <- cdr(l1)
    }
    result <- l2
    while (!is_nil(rev_l1)) {
      result <- cons(car(rev_l1), result)
      rev_l1 <- cdr(rev_l1)
    }
    result
  }
  force(l1)
  force(l2)
  lazy_thunk <- function(lst) function() lst()
  lazy_thunk(do_cat(l1, l2))
}
```

Now, the concatenation is a fast operation

```{r}
microbenchmark(lst <- cat(l1, l2), times = 1)
```

The first time we access the list, though, we pay for the concatenation. We only pay the first time, though.

```{r}
microbenchmark(car(lst), times = 1)
microbenchmark(car(lst), times = 1)
```

We still haven't achieved much by doing this. We have just moved the cost of concatenation from the `cat` call to the first time we access the list. If we abandon the loop-version of the concatenation function, though, and go back to the recursive version, we can get a simpler version where all operations are constant time.

```{r}
cat <- function(l1, l2) {
  force(l1)
  force(l2)
  if (is_nil(l1)) l2
  else {
    lazy_thunk <- function(lst) function() lst()
    lazy_thunk(cons(car(l1), cat(cdr(l1), l2)))
  }
}
```

In this function, we don't actually need to `force` `l1` since we directly use it, but just for consistency I will always `force` the arguments in functions that return thunks.

We abandoned this version of the concatenation function because we would recurse too deeply on long lists, but by wrapping the recursive call in a thunk that we evaluate lazily we do not have this problem. When we evaluate the result we get from calling this `cat` we only do one step of the concatenation recursion. Now, concatenation is a relatively fast operation---it needs to set up the thunk but it doesn't do any work on the lists:

```{r}
microbenchmark(lst <- cat(l1, l2), times = 1)
```

The first time we access the concatenated lists we need to evaluate the thunk. This is fast compared to actually concatenating them and is a constant time operation:

```{r}
microbenchmark(car(lst), times = 1)
```

Subsequent access to the head of the list is even faster. Now the thunk has already been evaluated, so we just access the list structure at the head:

```{r}
microbenchmark(car(lst), times = 1)
microbenchmark(car(lst), times = 1)
```

If we could do the same thing with list reversal, we would have a queue with constant time worst-case operations right away, but unfortunately we cannot. We could try implementing it like this:

```{r}
reverse <- function(lst) {
  r <- function(l, t) {
    force(l)
    force(t)
    if (is_nil(l)) t
    else {
      lazy_thunk <- function(lst) function() lst()
      lazy_thunk(r(cdr(l), cons(car(l), t)))
    }
  }
  r(lst, nil)
}
```

This, however, just constructs a lot of thunks that when we evaluate the first---which we do at the end of the function---calls the entire recursion. Now, both reversing the list and accessing it will be slow operations.

```{r}
l <- vector_to_list(1:500)
microbenchmark(lst <- reverse(l), times = 1)
microbenchmark(car(lst), times = 1)
```

It is even worse than that. Because we are reversing the list recursively, we will recurse too deeply for R when we call the function on a long list.

Wrapping the recursion in thunks might make it seem as if we are not recursing, but we are constructing thunks that, when evaluated, will call the computation all the way to the end of the list. We are really just implementing a complex version of the recursive reversal we had earlier.

We could make accessing the list cheap by wrapping the reversal in a thunk, but since we cannot get the head of a reversed list without going to the end of the original list, we cannot make reversal into a constant time operation. The best we can do is to use the iterative reversal from earlier and wrap it in a thunk so we at least get the reversal call as a cheap operation.

```{r}
reverse <- function(lst) {
  do_reverse <- function(lst) {
    result <- nil
    while (!is_nil(lst)) {
      result <- cons(car(lst), result)
      lst <- cdr(lst)
    }
    result
  }
  force(lst)
  lazy_thunk <- function(lst) {
    function() lst()
  }
  lazy_thunk(do_reverse(lst))
}
```

With this implementation, setting up the reversal is cheap, the first time we access the list we pay for it, but subsequent access is cheap again.

```{r}
l <- vector_to_list(1:10000)
microbenchmark(lst <- reverse(l), times = 1)
microbenchmark(car(lst), times = 1)
microbenchmark(car(lst), times = 1)
```

Since reversing the back list of a queue is the expensive operation, and since we cannot get away from that with lazy lists, it seems like we are not getting far, but we did gain a little. Now, at least, we only pay for a reversal once, so we can access a queue that has just reversed its back list and only pay for the operation the first time. If we use the queue persistently, we can access the same queue cheaper in any following operations. Of course, nothing prevents us them from going back to the queue in the state it was just *before* we called the reversal and start from there, and then we are back to potentially calling expensive operations more than once.

To do slightly better, we will need to construct lists that contain partly reversed and partly correctly-ordered lists as we update the queue.

### Amortised constant time, logarithmic worst-case, lazy queues

Following @okasaki_1995 we will work our way up to a queue solution with worst-case constant time operations by first implementing a version that has constant time amortised operations, even when used as a persistent data structure, and where the worst-case time usage for any operation is logarithmic in the queue length. This is an improvement upon the previous queues on both accounts, at least if we use the implementation as a persistent queue or if we need it to be fast for each operation, for example if we use it in interactive code. The lazy evaluation does add some overhead, see [@fig:lazy-queue-comparisons], so if these features are not needed, the environment based queue is still superior.

![Comparison between the ephemeral environment based queue and lazy queues.](figures/lazy-queue-comparisons){#fig:lazy-queue-comparisons}

We represent the queue as a front and back list as before, and we have to keep track of the list lengths in this data structure as well. In this case we will use lazy lists, but we will get to that. The constructor for the queue looks like this:

```r
lazy_queue <- function(front, back, front_length, back_length) {
  structure(list(front = front, back = back, 
                 front_length = front_length, 
                 back_length = back_length),
            class = "lazy_queue")
}
```

We can construct an empty queue, and check for emptiness, like this:

```r
empty_lazy_queue <- function() lazy_queue(nil, nil, 0, 0)
is_empty.lazy_queue <- function(x) 
  is_nil(x$front) && is_nil(x$back)
```

We will have the following invariant for the queue: the back list can at most be one longer than the front list. Whenever the back list grows larger than the front list, we are going to move  the elements in it to the front queue, but we will do so lazily.

The implementation of the queue is based on a "rotate" function that combines concatenation and reversal. The function looks like this:

```r
rot <- function(front, back, a) {
  force(front)
  force(back)
  force(a)
  if (is_nil(front)) cons(car(back), a)
  else {
    lazy_thunk <- function(lst) function() lst()
    lazy_thunk(cons(car(front), 
                    rot(cdr(front), cdr(back), cons(car(back), a))))
  }
}
```

It operates on three lists, the front list, the back list, and an accumulator. The idea behind the rotation function is that it concatenates the front list to the back list in a lazy recursion, just as the concatenation function we wrote above, but at the same time it reverses the back list one step at a time. We will call it whenever the front list is one element shorter than the back list. For each step in the concatenation, we also handle one step of the reversal. If the front list is empty, we put the first element of the back list in front of the accumulator. The queue invariant guarantees us that if the front list is empty, the back queue only contains a single element. The recursive call, wrapped in a thunk, puts the first element of the front list at the beginning of a list and then makes the continuation of the list another rotation call.

To make sure that we call the rotate function whenever we need to, to satisfy the invariant, we wrap all queue construction calls in the following function:

```r
make_q <- function(front, back, front_length, back_length) {
  if (back_length <= front_length)
    lazy_queue(front, back, front_length, back_length)
  else
    lazy_queue(rot(front, back, nil), nil, 
               front_length + back_length, 0)
}
```

Its only purpose is to call rotate when we need to. Otherwise, it just construct a queue.

The implementation of the queue abstract interface is relatively straightforward once we have these two functions:

```r
enqueue.lazy_queue <- function(x, elm) 
  make_q(x$front, cons(elm, x$back),
         x$front_length, x$back_length + 1)

front.lazy_queue <- function(x) car(x$front)

dequeue.lazy_queue <- function(x) 
  make_q(cdr(x$front), x$back,
         x$front_length - 1, x$back_length)
```

When we enqueue an element, we add it to the back list, when we need the front element, we get it from the front list---which can't be empty unless the entire queue is empty---and when we dequeue an element we just shorten the front list. All this is wrapped in calls to `make_q` that calls `rot` when needed.


We can see how the queue works in action by going through a few operations and see what the lists look like after each. We start with making an empty queue. It will have two empty lists.

```
q <- empty_lazy_queue()

Front: nil
Back: nil
```

If we now add an element, we will prepend it to the back list and then call `make_q` that will call `rot` because the back list is longer than the front list. In `rot` we see that the front list is empty so we have the base case where we just return the singleton list containing the element in the back list.

```
q < enqueue(q, 1)

Front: cons(1, nil)
Back: nil
```

If we add a second element, we will see in `make_q` that the back and front lists have the same length, so we just prepend the element to the back list.

```
q < enqueue(q, 2)

Front: cons(1, nil)
Back: cons(2, nil)
```

Inserting the third element, we get the first real rotation. We prepend 3 to the back list so it now contains the sequence (3,2) while the front list contains (1), and we then construct a list with the head 1 and the tail the rotation of `nil`, 2 and 3, but wrap that in a thunk.

```
q < enqueue(q, 3)

Front: lazy_thunk(
	cons(1, rot(nil, cons(2, nil), cons(3, nil)))
)
Back: nil
```

If we get the `front` of the queue or if we `dequeue` it, we will evaluate the thunk, which forces the evaluation of the rotation. Since the rotation is on an empty front list, it doesn't produce a new recursive rotation but directly produces a `cons` call.

```
q < front(q)

Front: lazy_thunk(
	cons(1, cons(2, cons(3, nil)))
)
Back: nil
```

At this point the entire back list has been reversed and appended to the front queue, and from here on we can just dequeue the elements. The first dequeueing gets rid of the thunk as well as the first element

```
q < dequeue(q)

Front: cons(2, cons(3, nil))
Back: nil
```

Other `dequeue` operations are now straightforward.

Let us go back to the empty list and insert six elements.

```
q <- empty_lazy_queue()
for (x in 1:6)
  q <- enqueue(q, x)

Front: lazy_thunk(
	cons(1, rot(nil, cons(2, nil), cons(3, nil)))
)
Back: cons(6, cons(5, cons(4, nil)))
```

Now, the front and back lists have the same length, so at the next `enqueue` operation we will have to insert a rotation. This will force an evaluation of the thunk that is the front list, forcing in turn an evaluation of the `rot` function as we saw before, and then it will construct a new thunk wrapping this.

```
q <- enqueue(q, 7)

Front: lazy_thunk(
	cons(1, rot(cons(2, cons(3, nil)),
	            cons(6, cons(5, cons(4, nil))),
	            cons(7, nil)))
)
Back: nil
```

Accessing the front of the queue will trigger an evaluation of the thunk, calling one level of recursion on `rot`.

```
front(q)

Front: lazy_thunk(
	cons(1, cons(2, rot(cons(3, nil)),
	                    cons(5, cons(4, nil)),
	                    cons(6, cons(7, nil))))
)
Back: nil
```

Dequeueing doesn't add another rotation since it wrapped in a thunk---although that is no so clear from my notation here, there is a thunk wrapping the `rot` call at the second level.

```
q <- dequeue(q)

Front: lazy_thunk(
	cons(2, rot(cons(3, nil)),
	            cons(5, cons(4, nil)),
	            cons(6, cons(7, nil)))
)
Back: nil
```

Calling `front` on this queue will again force an evaluation of `rot`

```
front(q)

Front: lazy_thunk(
	cons(2, cons(3, rot(nil,
	                    cons(4, nil),
	                    cons(5, cons(6, cons(7, nil))))
)
Back: nil
```

You can continue the example, and I advice you to if you really want to understand how we simulate a data structure by modifying lazy expressions.


For the amortised complexity analysis we can reason as before: whenever we add an element to the back queue it also pays for moving the element to the front queue at a later time. So any sequence of operations will be bounded by the number of constant-time insertions, just as before. Because the lazy evaluation mechanism we have implemented remembers the result of evaluating an expression, we also get the same complexity if we use the queue persistently. If we need to perform expensive operations, which we will need when we remove elements from the front of the queue, this might be costly the *first* time we remove an element from a given queue, but if we remove it again, because we do operations on a saved queue after we have modified it somewhere else, then the operation will be cheap.

For the worst-case complexity analysis, we first notice that enqueue operations always take constant time. We first add an element to the front of the back list, which is a constant time operation, and after that we might call `rot`. Calling `rot` only constructs a thunk, however, which again is a constant time operation. We don't pay for rotations until we access the list a `rot` call wraps.

With `front` and `dequeue` we access lazy lists, so here we might have to actually call the rotation operation. Although the operation looks like it would be a constant time operation

```r
lazy_thunk(cons(car(front), 
                rot(cdr(front), cdr(back), cons(car(back), a))))
```

this is a deception. We construct a new list from the first element in `front` and then add a thunk to the end of it, and this is a constant time operation if `front` is a simple list, but it *could* involve another call to `rot` that we need to call recursively. If `front` is another call to `rot`, however, the front of the list we have in that call cannot be longer than half the length of `front` because we only construct `rot` thunks when the front is the same length as the back list. So we might have to call `rot` several times, but each time, the front list will have half the length as the previous. This mean that we can at most have 
#ifdef EPUB
log(n)
#else
$\\log(n)$
#endif
calls to `rot`, so each call to `front` and `dequeue` can at most involve logarithmically many operations.

To get constant worst-time operations, we need to do a little more rotation work in enqueuing operations so these will pay for reversals, but before we get to that, I just want to take a closer look at the `rot` function and notice some R specific technicalities.

In the `rot` function we `force` all the parameters.

```r
rot <- function(front, back, a) {
  force(front)
  force(back)
  force(a)
  if (is_nil(front)) cons(car(back), a)
  else {
    lazy_thunk <- function(lst) function() lst()
    lazy_thunk(cons(car(front), 
                    rot(cdr(front), cdr(back), cons(car(back), a))))
  }
}
```

We typically have to `force` arguments to avoid problems that occur when expressions refer to variables that might have changed in the calling environment. That never happens in this queue implementation. Our queue implementation is purely functional and we never modify any variables. So, in theory, we shouldn't have to `force` the parameters. It turns out that we *do* need to `force` them, at least we do need to `force` the accumulator, and exploring why gives us some insights into lazy evaluation in R.

Try modifying the function to look like this:

```r
rot <- function(front, back, a) {
  if (is_nil(front)) cons(car(back), a)
  else {
    lazy_thunk <- function(lst) function() lst()
    lazy_thunk(cons(car(front), 
                    rot(cdr(front), cdr(back), cons(car(back), a))))
  }
}
```

If you then run this code

```r
q <- empty_lazy_queue()
for (x in 1:10000) {
  q <- enqueue(q, x)
}
for (i in 1:10000) {
  q <- dequeue(q)
}
```

you will find that you call functions too deeply.^[How deep you can recurse depends on your R setup, so you might have to increase the number of elements you run through in the loops, but with a standard configuration this should be enough to get an error.]

With the analysis we have done on how deep we will recurse when we rotated, that shouldn't happen. We might get a few tens deep in function calls with a sequence of ten thousands operations, but that shouldn't be a problem at all. So what is going wrong?

The problem is the lazy evaluation of the accumulator. In the recursive calls we update the accumulator to be `cons(car(back), a))`, which is something we should be able to evaluate in constant time, but we don't actually do this. Instead, we pass the *expression* for the `cons` call along in the recursive call. It doesn't actually get evaluated until we access the accumulator. At *that* time, all the `cons` calls need to be evaluated, and that can involve a *lot* of function calls; we have to call `cons` for as many times as `a` is long. By not forcing `a` we are delaying too much of the evaluation.

The most common pitfall with R's lazy evaluation of parameters is the issue with changing variables. That problem might cause your functions to work incorrectly. This is a different pitfall that will give you the right answer if you get one, but might involve evaluating many more functions than you intended. You avoid it by always being careful to `force` parameters when you return a closure, but in this case we could also explicitly evaluate the `cons(car(back),a)` expression:

```r
rot <- function(front, back, a) {
  if (is_nil(front)) cons(car(back), a)
  else {
    lazy_thunk <- function(lst) function() lst()
    tail <- cons(car(back), a)
    lazy_thunk(cons(car(front), rot(cdr(front), cdr(back), tail)))
  }
}
```

We are swimming in shark-infested waters when we use lazy evaluation, so we have to be careful. If we always `force` parameters when we can, though, we will avoid most problems.


### Constant time lazy queues

The rotation function performs a little of the reversal as part of constant time insertion operations, which is why we get a worst-case performance better than linear time. With making do just a little more, we can get constant time worst-case behaviour. There will still be a slight overhead with this version compared to the ephemeral queue implementation, see [@fig:lazy-worstcase-queue-comparisons], so if you don't need your queues to be persistent or fast for *ever* operation, the first solution we had is still superior. If you *do* need to use the queue as a persistent structure or you need guaranteed constant time operations, then this new variation is the way to go.

![Comparison of the ephemeral queue and the worst-case constant time lazy queue.](figures/lazy-worstcase-queue-comparisons){#fig:lazy-worstcase-queue-comparisons}

The worst-case constant time lazy queue uses the same rotation function as the 
#ifdef EPUB
log(n)
#else
$\\log(n)$
#endif
worst-case queue, but it uses a helper list that is responsible for evaluating part of the front queue as part of other queue operations. With the rotation function, we handle the combination of concatenation and reversal to move elements from the back list to the front list as part of other operations. We will use the helper list to evaluate the thunks that the front list consist of as part of other operations. If we evaluate them as part of other operations, then, when we need to access the front list, the lazy expressions have been evaluated and we can access the list in constant time.

Instead of keeping track of the length of the lists in the `lazy_queue` data structure, we just keep the extra helper list. We do not need to know the length of the lists in this implementation; we only need checks for empty lists.

```r
lazy_queue <- function(front, back, helper) {
  structure(list(front = front, back = back, helper = helper),
            class = "lazy_queue")
}
```

We then modify the `make_q` function to this:

```r
make_q <- function(front, back, helper) {
  if (is_nil(helper)) {
    helper <- rot(front, back, nil)
    lazy_queue(helper, nil, helper)
  } else {
    lazy_queue(front, back, cdr(helper))
  }
}
```

and we update the constructor and generic functions to reflect the changed data structure:

```r
empty_lazy_queue <- function() 
  lazy_queue(nil, nil, nil)
is_empty.lazy_queue <- function(x)
  is_nil(x$front) && is_nil(x$back)

enqueue.lazy_queue <- function(x, elm)
  make_q(x$front, cons(elm, x$back), x$helper)
front.lazy_queue <- function(x) car(x$front)
dequeue.lazy_queue <- function(x)
  make_q(cdr(x$front), x$back, x$helper)
```



You should think of `helper` more as a pointer into the front list than a separate list itself. Its purpose is to walk through the elements in the front list and evaluate them, leaving just a list behind. The lazy lists we are working with are conceptually immutable, but because of lazy evaluation, some consist of simple `cons` calls and others of `rot` calls. As we progress through the `helper` function, we translate the recursive `rot` calls into `cons` calls---conceptually, at least; the actual list still consists of the `rot` call but the value in the function has been evaluated. Since `helper` refers to a suffix of the `front` list at any time in the evaluation of queue operations, the effect of evaluating expressions in `helper` makes operations on `front` cheap.

Whenever we construct a queue with `make_q` we either set up a new rotation of the front and back queue or we evaluate the first function in the `helper` list. We can see this in action through an example. We start with an empty list and insert an element. This involves a call to `rot` as in the earlier version of the lazy queue but this time we also set the helper list to point to the front list.

```
q <- empty_lazy_queue()
q <- enqueue(q, 1)

Front: cons(1, nil)
Helper: cons(1, nil)
Back: nil
```

When we insert a second element this gets prepended to the back list and we make one step with the helper function, moving it to the empty list.

```
q <- enqueue(q, 2)

Front: cons(1, nil)
Helper: nil
Back: cons(2, nil)
```

With the third element, we again need a rotate call, since now the helper list is empty.

```
q <- enqueue(q, 3)

Front: cons(1, rot(nil, cons(2, nil), cons(3, nil)))
Helper: cons(1, rot(nil, cons(2, nil), cons(3, nil)))
Back: nil
```

If we now continue inserting elements into the queue we can see how the helper function will walk through the front queue and evaluate the expressions there, updating the front queue at the same time, as we insert new elements to the back queue.

```
q <- enqueue(q, 4)

Front: cons(1, cons(2, cons(3, nil)))
Helper: cons(2, cons(3, nil))
Back: cons(4, nil)
```

```
q <- enqueue(q, 5)

Front: cons(1, cons(2, cons(3, nil)))
Helper: cons(3, nil)
Back: cons(5, cons(4, nil))
```

```
q <- enqueue(q, 6)

Front: cons(1, cons(2, cons(3, nil)))
Helper: nil
Back: cons(6, cons(5, cons(4, nil)))
```

When we insert the seventh element, we again need a rotation, but now all the lazy expressions in the front queue have been evaluated. 

```
q <- enqueue(q, 7)

Front: cons(1, rot(cons(2, cons(3, nil)),
                   cons(6, cons(5, cons(4, nil))),
                   cons(7, nil)))
Helper: cons(1, rot(cons(2, cons(3, nil)),
                    cons(6, cons(5, cons(4, nil))),
                    cons(7, nil)))
Back: nil
```

In future operations, `helper` will walk through the front queue again and evaluate tails of the function.

```
q <- enqueue(q, 8)

Front: cons(1, cons(2, rot(cons(3, nil),
                           cons(5, cons(4, nil)),
                           cons(6, cons(7, nil)))))
Helper: cons(2, rot(cons(3, nil),
                    cons(5, cons(4, nil)),
                    cons(6, cons(7, nil))))
Back: cons(8, nil)
```

```
q <- enqueue(q, 9)

Front: cons(1, cons(2, cons(3, 
          rot(nil,
              cons(4, nil), 
              cons(5, cons(6, cons(7, nil)))))))
Helper: cons(3, rot(nil,
                    cons(4, nil),
                    cons(5, cons(6, cons(7, nil)))))
Back: cons(9, cons(8, nil))
```

```
q <- enqueue(q, 10)

Front: cons(1, cons(2, cons(3, 
          cons(4, cons(5, cons(6, cons(7, nil)))))))
Helper: cons(4, cons(5, cons(6, cons(7, nil))))
Back: cons(10, cons(9, cons(8, nil)))
```

We don't just progress the evaluation of the helper function when we add elements, we also move it forward when removing elements.

```
q <- dequeue(q)

Front: cons(2, cons(3, 
          cons(4, cons(5, cons(6, cons(7, nil))))))
Helper: cons(5, cons(6, cons(7, nil)))
Back: cons(10, cons(9, cons(8, nil)))
```

```
q <- dequeue(q)

Front: cons(3, cons(4, cons(5, cons(6, cons(7, nil)))))
Helper: cons(6, cons(7, nil))
Back: cons(10, cons(9, cons(8, nil)))
```

```
q <- dequeue(q)

Front: cons(4, cons(5, cons(6, cons(7, nil))))
Helper: cons(7, nil)
Back: cons(10, cons(9, cons(8, nil)))
```

```
q <- enqueue(q, 11)

Front: cons(4, cons(5, cons(6, cons(7, nil))))
Helper: nil
Back: cons(11, cons(10, cons(9, cons(8, nil))))
```

We do not insert the next rotation until the helper list is empty, at which point the entire front list has been lazy evaluated. It exactly because of this, that the helper function goes through the front list and performs rotations one element in the list at a time, that the worst-case performance is constant time.

With a little more work, it is possible to to adapt this strategy to double-ended queues as well. For that construction, I refer to @okasaki_1995.