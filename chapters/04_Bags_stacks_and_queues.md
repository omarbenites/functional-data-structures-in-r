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

We have to be a little careful with functions such as `lazy_thunk`. The `expr` parameter will be evaluated when we call the thunk the first time, but it will be evaluated in the calling scope where we constructed the thunk but as it looks when we evaluate the thunk. If it depends on variables that have been modified since we created the thunk, the expression we get might not be the one we want. The function `force` is typically used to alleviate this problem. It forces the evaluation of a parameter so it evaluates to values that matches the expression at the time the thunk is constructed. This won't work here, though---we explicitly do not want the expression evaluated.

If we are careful with how we use thunks and make sure that we give them expressions where any variables have already been forced, though, we can exploit lazy evaluation of function parameters to implement lazy expressions.

### Lazy lists