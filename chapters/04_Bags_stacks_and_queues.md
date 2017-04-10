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
insert.tree_bag <- function(x, elm, ...) {
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



## Queues
