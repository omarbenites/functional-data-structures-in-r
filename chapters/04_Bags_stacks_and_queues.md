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

We can compare the time usage of the three queue implementations in practise, see [@fig:queues-comparisons]. The two environment based implementations run in the same wall time but there is an extra overhead in the functional implementation. This is caused by wrapping the newly constructed queues in a new structure each time---on top of wrapping lists in structures whenever we manipulate them.

![Comparison of the running time for constructing and emptying the three implementations of queues.](figures/queues-comparisons){#fig:queues-comparisons)

We could speed up the implementation if we were willing to not wrap the implementation as an abstract data structure---and we could do the same if we didn't represent the lists as objects and just used head and tail pointers---but implementing a functional queue with the amortised complexity to avoid side-effects isn't as useful as it might sound. The amortised complexity we achieve is very good if we treat the queues as ephemeral data structures, but not actually that great for persistent data structures as you might think. The amortised analysis simply doesn't work if we want to use the queue as a persistent data structure.

### Amortised time complexity and persistent data structures



### Dequeues

### Worst-case constant time lazy queues

