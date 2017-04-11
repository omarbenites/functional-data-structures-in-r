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

Merging can now be done in constant time. We need to be careful not to create inner nodes with empty subtrees, but otherwise we can just create a node that has the two bags we merge as its left and right subtrees:

```r
merge.tree_bag <- function(x, y) {
  if (is_empty(x)) return(y)
  if (is_empty(y)) return(x)
  bag_node(NA, x, y)
}
```

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
$n\log(n)$
#endif
algorithms are straightforward: we can sort the bags and merge them---this would take 
#ifdef EPUB
n log(n)
#else
$n\log(n)$
#endif
for the sorting and then linear time for merging them, or we could simply put all the bag elements into a search tree and extract them from there. We can sort elements in this complexity using the heap data structure, see [@sec:heaps], and we can construct and extract the unique elements in a search tree, see [@sec:sets-and-search-trees].

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

So, we can implement a queue as two lists. A problem presents itself now, though. Updating and querying the data structure are not completely separate operations any longer. If we try to get the `front` element of a queue, we might have to update the queue; if the front list is empty and the back list is not, we need to move all the elements from the back list to the front list before we can get the front element. This is something we will generally want to avoid; if querying a data structure also modifies it, we will need to return both the result of queries and the updated data structure on these operations, which breaks the clean interface and makes for some ugly code. It is, however, not unusual that we have persistent data structures with good amortised time complexity, if not worst case complexity, that relies on modifying them when we query them, so implementing this queue solution gives me the opportunity to show you a general trick for handling queries that modify data structures in R: using environments that we *can* modify. After that, I will show you a simpler solution for queues---we can actually extend the representation of queues a tiny bit to avoid the problem, but this isn't always possible, so it is worth knowing the general trick.

What we want, essentially, is to have `front` have the side effect of moving elements from the back of the queue and to the front in case the front list is empty. With the `dequeue` operation, we don't have a problem; that operation returns an updated queue in any case. But `front` should only return the front of the list---any new queue it might need to construct isn't returned. If it was entirely impossible for R functions to have side effects, that would be the end of this strategy, but R is not a pure functional language and some side effects are possible. We cannot modify data, but we can modify environments. We can change the binding of variables to data values. We can construct a queue that we can query and modify at the same time, if we use an environment to hold values we need to update. We can do this explicitly using an environment object, or implicitly using closures. Of course, both environment based solutions will not give us a persistent data structure. Because we do introduce side effects, we get a more traditional ephemeral data structure---but at the end of the chapter you will see how we get a persistent queue, so no worries.

### Side effects through environments

```r
queue_environment <- function(front, back) {
  e <- new.env(parent = emptyenv())
  e$front <- front
  e$back <- back
  class(e) <- c("env_queue", "environment")
  e
}

empty_env_queue <- function()
  queue_environment(empty_list(), empty_list())

is_empty.env_queue <- function(x)
  is_empty(x$front) && is_empty(x$back)

enqueue.env_queue <- function(x, elm) {
  x$back <- list_cons(elm, x$back)
  x
}

front.env_queue <- function(x) {
  if (is_empty(x$front)) {
    x$front <- list_reverse(x$back)
    x$back <- empty_list()
  }
  list_head(x$front)
}

dequeue.env_queue <- function(x) {
  if (is_empty(x$front)) {
    x$front <- list_reverse(q$back)
    x$back <- empty_list()
  }
  x$front <- list_tail(x$front)
  x
}
```

### Side effects through closures

```r
queue <- function(front, back)
  list(front = front, back = back)

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
      q <<- queue(list_reverse(q$back), empty_list())
    }
    q$front <<- list_tail(q$front)
  }

  structure(list(is_empty = queue_is_empty,
                 enqueue = enqueue,
                 front = front,
                 dequeue = dequeue),
            class = "closure_queue")
}

empty_queue <- function() queue_closure()
```

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

### A purely functional queue

```r
queue_extended <- function(x, front, back)
  structure(list(x = x, front = front, back = back),
            class = "extended_queue")

empty_extended_queue <- function() queue_extended(NA, empty_list(), empty_list())
is_empty.extended_queue <- function(x)
  is_empty(x$front) && is_empty(x$back)

enqueue.extended_queue <- function(x, elm)
  queue_extended(ifelse(is_empty(x$back), elm, x$x),
                 x$front, list_cons(elm, x$back))

front.extended_queue <- function(x) {
  if (is_empty(x)) stop("Taking the front of an empty list")
  if (is_empty(x$front)) x$x
  else list_head(x$front)
}

dequeue.extended_queue <- function(x) {
  if (is_empty(x)) stop("Taking the front of an empty list")
  if (is_empty(x$front))
    x <- queue_extended(x$x, list_reverse(x$back), empty_list())
  queue_extended(NA, list_tail(x$front), x$back)
}
```
