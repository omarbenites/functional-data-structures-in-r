# Heaps {#sec:heaps}

Heaps, or priority queues, are collections of elements from an ordered set where, besides checking for emptiness and inserting elements

```{r, eval=FALSE}
is_empty <- function(x) UseMethod("is_empty")
insert <- function(x, elm) UseMethod("insert")
```

we can also access and delete the smallest element.^[I will implement all the heaps in this chapter to have access to the minimal element. It is a trivial modification to have access to the largest instead.]

```{r, eval=FALSE}
find_minimal <- function(heap) UseMethod("find_minimal")
delete_minimal <- function(heap) UseMethod("delete_minimal")
```

Heaps are not necessarily sets. It is possible for heaps to have multiple elements with the same value.

In addition to these operations, we will also require that we can merge two heaps.

```{r, eval=FALSE}
merge <- function(x, y) UseMethod("merge")
```

In many of the implementations, we have use for this merge function, and we can always implement a default version like this:

```{r, eval=FALSE}
merge.default <- function(x, y) {
  while (!is_empty(y)) {
    x <- insert(x, find_minimal(y))
    y <- delete_minimal(y)
  }
  x
}
```

Since we already used `merge` with bags, though, we probably shouldn't make this default implementation of the generic function. Instead, we can make a version for heaps

```{r, eval=FALSE}
merge.heap <- function(x, y) {
  while (!is_empty(y)) {
    x <- insert(x, find_minimal(y))
    y <- delete_minimal(y)
  }
  x
}
```

and make all our heap implementations inherit from a generic `"heap"` class. 

This heap merging will work for all heaps, but usually there are more efficient solutions for merging heaps. This default solution will require a number of `find_minimal` and `delete_minimal` operations equal to the size of heap `y`, and at the very least this will be linear in the size of `y`. As we will see, we can usually do better.

One use of heaps is sorting elements. This approach is known as heap sort. If we have a heap, we can construct a list from its element in reverse order using a loop similar to the `merge.default` function:

```{r, eval=FALSE}
heap_to_list <- function(x) {
  l <- empty_list()
  while (!is_empty(x)) {
    l <- list_cons(find_minimal(x), l)
    x <- delete_minimal(x)
  }
  l
}
```

This function creates a linked list from a heap, but the elements are added in decreasing rather than increasing order, so to implement a full sort we need to reverse it. Of course, to sort a vector of elements, we also need to construct the heap from the elements. One general approach is, of course, to just insert all the elements into a heap, starting from the empty heap.

```{r, eval=FALSE}
vector_to_heap <- function(empty_heap, vec) {
  heap <- empty_heap
  for (e in vec)
    heap <- insert(heap, e)
  heap
}
```

With the `vector_to_heap` and `heap_to_list` functions, we can sort elements thus:  

```{r, eval=FALSE}
heap_sort <- function(vec, empty_heap) {
  heap <- vector_to_heap(empty_heap, vec)
  lst <- heap_to_list(heap)
  list_reverse(lst)
}
```

The time complexity of the `heap_sort` function depends on the time complexity of the heap operations. We can reverse `lst` in the function in linear time. If `insert`, `find_minimal`, and `delete_minimal` all run in logarithmic time, the entire sort can be done in time
#ifdef EPUB
O(n log(n))
#else
$O(n\\log(n))$
#endif
which is optimal for comparison based sorting. Since we know that this is an optimal time for sorting, this also gives us some hints at how efficient we can hope the heap data structures to be. Either `vector_to_heap` or `heap_to_list` *must* take time
#ifdef EPUB
O(n log(n))
#else
$O(n\\log(n))$
#endif
as a tight upper bound on the complexity if we have an optimal sorting algorithm.

As it turns out, we can usually construct a heap from
#ifdef EPUB
n
#else
$n$
#endif
elements in linear time but it will take us 
#ifdef EPUB
O(n log(n))
#else
$O(n\\log(n))$
#endif
time to extract the elements again. Constructing heaps in linear time uses the `merge` function. Instead of adding one element at a time, we construct a sequence of heaps and merge them. The construction looks like this:

```{r, eval=FALSE}
singleton_heap <- function(empty_heap, e) insert(empty_heap, e)
vector_to_heap <- function(vec, empty_heap, empty_queue) {
  q <- empty_queue
  for (e in vec)
    q <- enqueue(q, singleton_heap(empty_heap, e))
  repeat {
    first <- front(q) ; q <- dequeue(q)
    if (is_empty(q)) break
    second <- front(q) ; q <- dequeue(q)
    new_heap <- merge(first, second)
    q <- enqueue(q, new_heap)
  }
  first
}
```

We start by constructing a singleton heap containing just a single of the input elements. Then, we put these in a queue and while we have more than one queue we take the first two out of the queue, merge them, and put them back at the end of the queue. You can think of this as going through several phases of heaps. The first phase merges heaps of size one into heaps of size two. The second phase merges heaps of size two into heaps of size four. And so on. Since we can only double the heap size logarithmically many times, we have 
#ifdef EPUB
log(n)
#else
$\\log(n)$
#endif
phases. 

The size of the heaps we merge in phase $m$ is $2^m$, but if we can merge heaps in logarithmic time, we get the total time for constructing the heap in this way to be
$$
	\\sum_{m=0}^{\\log(n)} \\frac{n}{2^m}O(m)
	= O\\left( n \\sum_{m=0}^{\\log(n)} \\frac{m}{2^m}\\right)
$$
which, because the series 
$$
	\\sum_{m=0}^{\\infty} \\frac{m}{2^m}
$$
is convergent, is $O(n)$. So, if we can merge heaps in logarithmic time, we can construct a heap of $n$ elements in time $O(n)$.^[I am being a little lax with notation here. We cannot sum to $\\log(n)$ unless this is an integer, and strictly speaking it should be $\\lfloor\\log(n)\\rfloor$. This doesn't change the complexity analysis and I just don't feel like being too strict with the mathematics in a book that is primarily about R programming.] This also tells us that if we can merge heaps in logarithmic time, it most also cost us at least logarithmic time to either get the minimal value or delete it---otherwise we would be able to sort faster than $O(n\\log(n))$ which we know is impossible for comparison based sorting.

With this implementation of heap construction, we would have to modify the `heap_sort` function to look like this:

```{r, eval=FALSE}
heap_sort <- function(vec, empty_heap, empty_queue) {
  heap <- vector_to_heap(vec, empty_heap, empty_queue)
  lst <- heap_to_list(heap)
  list_reverse(lst)
}
```

It is parameterised with the empty heap and queue, which lets us choose which data structures to use. We know that the fastest queue implementation we have, when we do not need the queue to be persistent, is the environment based queue, so we could put that as the default empty queue to get a good algorithm. In the remainder of this chapter we will experiment with different heap implementations to see which heap would be a good default choice.


The heaps we will implement are based on trees. So they are slightly more complicated than the lists and queues we used in the previous chapter, but only slightly so. When we work with trees, we say that a tree has the "heap property" if every node in the tree contains a value and the nodes in the trees satisfy that all children of a node has values greater than the value in the node. By recursive reasoning, this means that if we have a tree with the heap property, then all subtrees also have the heap property. This will be an invariant that we will ensure for all the trees we work with.


## Leftist heaps

Leftist heaps are a classical implementation of heaps based on one simple idea: You represent the heap as a binary tree with the heap property, and you make sure that the left sub-tree is always at least as large as the right sub-tree.^[My description of leftist heaps is based on @okasaki1999purely. The original description of the data structure can be found in @Crane:1972:LLP:906397.] The structure exploits a general trick in data structure design known as "the smaller half" trick. If you have to do some computation recursively, but you only have to do it for one of two children in a binary tree, you pick the smaller of the two trees. If you do this, you slice away half of the size of the tree in each recursive call.[^smaller_half] If you slice away half the data in each recursive call, you can never recurse deeper than the logarithm of the full data size.

In the leftist heap we don't actually keep track of the full size of heaps to exploit this trick. We don't need trees to be balanced to operate efficiently on heaps. Instead, we worry about the total depth we might have to go to in recursions. We will always recurse to the right in the heap, so the length of the right-most path in a heap, which we will call its *rank*, is what we worry about, and we make sure that we always have the shortest path as the rightmost.

There is a variant of this called *maxiphopic heaps* [@Okasaki:2005:ATC:1047124.1047407] that makes this more explicit, but the underlying idea is the same; maxiphopic heaps just do not require that the larger sub-tree is the left tree.

[^smaller_half]: The "smaller half" name is an oxymoron. If we really split data in half, both half would be the same size. What we really mean is that we slice away at least one half of the data in each recursion. I didn't come up with the name, but that is the name I know the trick by.

To keep the invariant that the left sub-tree always have a smaller rank than the right sub-tree, we keep track of tree ranks. The structure we use to represent a leftist heap looks like this:

```{r, eval=FALSE}
leftist_heap_node <- function(
  value
  , left = empty_leftist_heap()
  , right = empty_leftist_heap()
  , rank = 0
  ) {
  structure(list(left = left, 
                 value = value, 
                 right = right, 
                 rank = rank),
            class = c("leftist_heap", "heap"))
}
```

The class of the structure is `"leftist_heap"` and then `"heap"`, in case we have general heap functions that are not specific to leftist heaps.

The empty list and the emptiness test uses the sentinel trick as we have used it earlier.

```{r, eval=FALSE}
empty_leftist_heap_node <- leftist_heap_node(NA, NULL, NULL)
empty_leftist_heap <- function() empty_leftist_heap_node
is_empty.leftist_heap <- function(x)
  identical(x, empty_leftist_heap_node)
```

Since a leftist heap has the heap property, we can always get the the minimal value from the root of the tree:

```{r, eval=FALSE}
find_minimal.leftist_heap <- function(heap) {
  heap$value
}
```

To delete the minimal value, we need to get rid of the value in the root. But since the two sub-trees of the root are heaps, we can create a new heap with the minimal value removed just by merging the two sub-trees.

```{r, eval=FALSE}
delete_minimal.leftist_heap <- function(heap) {
  merge(heap$left, heap$right)
}
```

Inserting an element is equally simple: we can make a singleton heap and merge it into the existing heap.

```{r, eval=FALSE}
insert.leftist_heap <- function(x, elm) {
  merge(x, leftist_heap_node(elm))
}
```

All the complexity of a leftist heap boils down to the `merge` operation. This is where we will exploit that the right sub-tree is never more than half the heap. If we merge two heaps, we take the minimal value in the root and put the left part of the first tree as the left sub-tree and then merge recursively on the right. Since this cuts the problem down to half the size, we will never spend more time than $O(\\log n)$.

```{r, eval=FALSE}
build_leftist_heap <- function(value, a, b) {
  if (a$rank >= b$rank)
    leftist_heap_node(value = value, 
                      left = a, 
                      right = b, 
                      rank = b$rank + 1)
  else
    leftist_heap_node(value = value, 
                      left = b, 
                      right = a, 
                      rank = a$rank + 1)
}

merge.leftist_heap <- function(x, y) {
  if (is_empty(x)) return(y)
  if (is_empty(y)) return(x)
  if (x$value <= y$value) 
	  build_leftist_heap(x$value, x$left, merge(x$right, y))
  else 
	  build_leftist_heap(y$value, y$left, merge(x, y$right))
}
```

The base cases of the `merge` operations just make sure that if either of the two heaps we merge are empty, we return the other. Otherwise, we call recursively on the right. We always put the smallest value in the root, to preserve the heap property, but after that we call recursively on half the problem. The smaller half trick does the trick for us to get logarithmic complexity.

Since we can immediately get the smallest value from the root of a leftist heap, the `find_minimal` operation runs in $O(1)$. The `insert` and `delete_minimal` operations work through the `merge` operation, so these operations run in time $O(\\log n)$.

I hope you agree that this implementation of a heap is very simple. There is only one trick to it---the smaller half trick---and the rest is just remembering to call recursively to the right and never to the left. It is surprising how powerful the smaller half trick really is. I have used in many different algorithms, and I'm always awed by how powerful that simple trick is.

But just because we have one solution to the heap data structure there is no reason to stop. It is worth exploring other solutions. Even if they are less efficient, which they might be if they are more complex to implement, there might be some insights to gain from implementing them...

## Binomial heaps

For a second version of heaps we turn to *binomial heaps*. My presentation of this data structure is also based on @okasaki1999purely. Binomial heaps are based on *binomial trees*, which are trees with the heap structure and the additional invariants (see [@fig:binomial-trees]):

* A binomial tree of rank 0 is a singleton.
* A tree of rank $r$ has $r$ children, $t_1,t_2,\\ldots,t_r$ where $t_i$ is a binomial tree with rank $r-i$.

![Binomial trees.](figures/binomial-trees){#fig:binomial-trees}

We are not going to use binomial trees as an abstract data structure, so we won't give them a class and simply implement them using a `list`:

```{r, eval=FALSE}
binomial_tree_node <- function(value, trees) {
  list(value = value, trees = trees)
}
```

We will build up binomial trees by *linking* them. This is an operation that we will only do on trees with the same rank, and what the operation does is that it makes one of the trees the left-most sub-tree of the other. If both trees have rank $r$, then this construct a new tree of rank $r+1$. To preserve the heap property, we must make sure that the parent tree is the one with the smallest value of the two. We can implement this operation as such:

```{r, eval=FALSE}
link_binomial_trees <- function(t1, t2) {
  if (t1$value < t2$value) {
    binomial_tree_node(t1$value, list_cons(t2, t1$trees))
  } else {
    binomial_tree_node(t2$value, list_cons(t1, t2$trees))
  }
}
```

Binomial trees are not themselves an efficient approach to building heaps. In fact, we cannot use them as heaps at all. We can, of course, easily get the minimal value from the root, but we cannot represent an arbitrary number of elements in binomial trees---they don't come in all sizes because of the invariants---and manipulation of binomial trees do not easily allow the heap operations. Instead, a binomial heap is a list of trees, each with their associated rank so we can keep track of those. The minimal value in the heap will be in one of the roots of these trees, but since finding it would require searching through the list, we will remember it explicitly.

```{r, eval=FALSE}
binomial_heap_node <- function(rank, tree) {
  list(rank = rank, tree = tree)
}
```

```{r, eval=FALSE}
binomial_heap <- function(min_value, heap_nodes = empty_list()) {
  structure(list(min_value = min_value, heap_nodes = heap_nodes),
            class = c("binomial_heap", "heap"))
}
```

With this structure, an empty binomial heap is just one with no binomial trees, and we don't need a sentinel to represent such.

```{r, eval=FALSE}
empty_binomial_heap <- function() binomial_heap(NA)
is_empty.binomial_heap <- function(x) is_empty(x$heap_nodes)
```

Since we explicitly represent the minimal value in the heap, the `find_minimal` function is trivial to implement:

```{r, eval=FALSE}
find_minimal.binomial_heap <- function(heap) {
  heap$min_value
}
```

We now insist on the following invariant for how the binomial trees are used in a binomial heap: no two trees can have the same rank. This creates a correspondence between the rank of binomial trees in a heap and the binary representation of the number of elements in the heap: for each 1 in the binary representation we will have a tree of that rank, see [@fig:binomial-heaps].

![Binomial heaps of size 0 to 5.](figures/binomial-heaps){#fig:binomial-heaps}

With this invariant in mind, we can think of both insertion and merging as a variant of binary addition. Insertion is the simplest case, so we deal with that first. To insert a new value in the heap, we first create a singleton heap node, with a binomial tree of rank 0 holding the value.

```{r, eval=FALSE}
singleton_binomial_heap_node <- function(value) {
  tree <- binomial_tree_node(value, empty_list())
  binomial_heap_node(0, tree)
}
```

We now need to insert this node in the list. If there is no node in there with rank 0 already, we can just put it in. If there is, however, that slot is taken and so we must do something else. We can link the existing tree of rank 0 with the new singleton, creating a node with rank 1. If that slot is free, we are done; if it is not, we must link again, and so on. Similar to how we carry a bit if we add binary numbers. If we always keep the trees in the heap ordered in increasing rank, this approach can be implemented like this:

```{r, eval=FALSE}
insert_binomial_node <- function(new_node, heap_nodes) {
  if (is_empty(heap_nodes)) {
    return(list_cons(new_node, empty_list()))
  }

  first_node <- list_head(heap_nodes)
  if (new_node$rank < first_node$rank) {
    list_cons(new_node, heap_nodes)
  } else {
    new_tree <- link_binomial_trees(new_node$tree, first_node$tree)
    new_node <- binomial_heap_node(new_node$rank + 1, new_tree)
    insert_binomial_node(new_node, list_tail(heap_nodes))
  }
}
```

The insert operation on the heap now consist of updating the minimal value, if necessary, and inserting the new value starting from a singleton:

```{r, eval=FALSE}
insert.binomial_heap <- function(x, elm, ...) {
  new_min_value <- min(x$min_value, elm, na.rm = TRUE)
  new_node <- singleton_binomial_heap_node(elm)
  new_nodes <- insert_binomial_node(new_node, x$heap_nodes)
  binomial_heap(new_min_value, new_nodes)
}
```

The `na.rm = TRUE` is necessary here to deal with the case where the heap is empty. We could have avoided it by using `Inf` as the value for an empty heap as well, but I find it nicer to explicitly state that an empty heap doesn't actually have a minimal value.

Merging two heaps also works similar to binary addition. We have the two heaps represented as lists of binary trees in increasing rank order, so we can implement this as list merge. Whenever the front of one list has a rank smaller than the front of the other, we can insert that element in the front of a list and make a recursive call, but when the two lists have fronts of equal rank we must link the two and merge the new tree in. We cannot simply put the new tree at the front of the merge since the existing lists might already have a slot for the rank of that tree, but we can insert it into the result of a recursive call, which will work like carrying a bit in addition.

```{r, eval=FALSE}
merge_heap_nodes <- function(x, y) {
  if (is_empty(x)) return(y)
  if (is_empty(y)) return(x)

  first_x <- list_head(x)
  first_y <- list_head(y)
  if (first_x$rank < first_y$rank) {
    list_cons(first_x, merge_heap_nodes(list_tail(x), y))
  } else if (first_y$rank < first_x$rank) {
    list_cons(first_y, merge_heap_nodes(list_tail(y), x))
  } else {
    new_tree <- link_binomial_trees(first_x$tree, first_y$tree)
    new_node <- binomial_heap_node(first_x$rank + 1, new_tree)
    rest <- merge_heap_nodes(list_tail(x), list_tail(y))
    insert_binomial_node(new_node, rest)
  }
}
```

The actual merge operation just needs to keep track of the new minimal value in addition to merging the heap nodes.

```{r, eval=FALSE}
merge.binomial_heap <- function(x, y, ...) {
  if (is_empty(x)) return(y)
  if (is_empty(y)) return(x)
  new_min_value <- min(x$min_value, y$min_value)
  new_nodes <- merge_heap_nodes(x$heap_nodes, y$heap_nodes)
  binomial_heap(new_min_value, new_nodes)
}
```

We don't need `na.rm = TRUE` in this case, since we handle empty heaps explicitly.^[If someone inserts `NA` into a heap, this would break, of course, but then, if someone does that he should have his head examined. With `NA` there is no ordering, so the whole purpose of having a priority queue goes out the window.]

The insertion operation is really just a special case of merge, as it was for leftist heaps, and we could have implemented it in terms of merging as this:

```{r, eval=FALSE}
insert_binomial_node <- function(new_node, heap_nodes) {
  merge_heap_nodes(list_cons(new_node, empty_list()), heap_nodes)
}
```

Here, we just need to make the new node into a list and merge that into the existing heap nodes.

The complexity of the merge operation comes from the correspondence to binary numbers. To represent a number of size $n$ we only need $\\log n$ bits, so for heaps of size $n$ the lists are no longer than $\\log n$. We are not simply merging them but have the added complexity of having to carry a bit, but even doing this, which is simply binary addition, the complexity remains $O(\\log n)$---the complexity of adding two numbers of size $n$ represented in binary. Since insertion is just a special case of merging, we can of course insert in $O(\\log n)$ as well.

Deleting the minimal value from a binomial heap is not really a more complex operation, it just involves a lot more code because we need to manipulate lists. The minimal value is found at the root of one of the trees in the heap. We need to find this tree and we need to delete it from the list of trees. We could do this in one function returning two values, but that would involve wrapping and unwrapping the return value, so we will handle it in two operations instead. We know which value to search for in the roots from the saved minimal value in the heap, so finding the tree containing it is just a linear search through the heap nodes, and deleting it is just as simple.

```{r, eval=FALSE}
get_minimal_node <- function(min_value, heap_nodes) {
  first_node <- list_head(heap_nodes)
  if (first_node$tree$value == min_value) first_node
  else get_minimal_node(min_value, list_tail(heap_nodes))
}

delete_minimal_node <- function(min_value, heap_nodes) {
  first_node <- list_head(heap_nodes)
  if (first_node$tree$value == min_value) {
    list_tail(heap_nodes)
  } else {
    rest <- delete_minimal_node(min_value, list_tail(heap_nodes))
    list_cons(first_node, rest)
  }
}
```

These are linear time operations in the length of the list, but since the list we operate on cannot be longer than $O(\\log n)$ we can do them in logarithmic time in the size of the heap.

Deleting the tree containing the smallest value certainly gets rid of that value, but also any other values that might be in that tree. We need to put those back into the heap. We will do this by merging them into the heap nodes. To do this, though, we need to associate them with their rank; we need to wrap them in the heap node structure. If the tree we are deleting has rank $r$, then we know that its first sub-tree has rank $r-1$, its second has rank $r-2$, and so forth, so we can iterate through the trees, carrying the rank to give to the front tree along, in a recursion that looks like this:

```{r, eval=FALSE}
binomial_trees_to_nodes <- function(rank, trees) {
  if (is_empty(trees)) {
    empty_list()
  } else {
    list_cons(binomial_heap_node(rank, list_head(trees)),
              binomial_trees_to_nodes(rank - 1, list_tail(trees)))
  }
}
```

If the tree we remove has rank $r$ this is an $O(r)$ operation, but since the ranks of the trees cannot be larger than $O(\\log n)$---again, think of the binary representation of a number---this is a logarithmic operation in the size of the heap. We need to merge them into the original list, with the minimal tree removed, but they are in the wrong order. The children of a binomial tree are ordered in decreasing rank but the trees in a binomial heap are ordered in increasing rank, so we will have to reverse the list before we merge; this, we can of course also do in time $O(\\log n)$ since it is a linear time operation in the length of the list.

In case you are wondering why we didn't just represent the children of binary trees in increasing order to begin with, it has to do with how we link two trees. We can link two trees in constant time because it just involves prepending a tree to a list of trees. If we wanted to store the trees in increasing rank order, we would need to append a tree to a list instead. This would either require linear time in the size of the trees ore a more complex data structure. It is easier simply to reverse the list at this point.

Since we are deleting the minimal value of the heap, we also need to update the value we store for that. Here, we can simply run through the new list once it is constructed and find the smallest value in the roots of the trees.

```{r, eval=FALSE}
binomial_nodes_min_value <- function(heap_nodes, cur_min = NA) {
  if (is_empty(heap_nodes)) {
    cur_min
  } else {
    front_value <- list_head(heap_nodes)$tree$value
    new_cur_min <- min(cur_min, front_value, na.rm = TRUE)
    binomial_nodes_min_value(list_tail(heap_nodes), new_cur_min)
  }
}
```

We drag the current minimal value along as an accumulator and give it the default value of `NA`. Therefore, we also need to use `na.rm = TRUE` when updating it, but using `NA` as its default value also guarantees that if we construct an empty heap when deleting the last element, it gets the minimal value set to `NA`.

All these operations take time $O(\\log n)$ and the `delete_minimal` operation is just putting them all together, so we have a $O(\\log n)$ operation that looks like this:

```{r, eval=FALSE}
delete_minimal.binomial_heap <- function(heap) {
  min_node <-
    get_minimal_node(heap$min_value, heap$heap_nodes)
  other_nodes <-
    delete_minimal_node(heap$min_value, heap$heap_nodes)
  min_node_nodes <-
    binomial_trees_to_nodes(min_node$rank - 1,
                            min_node$tree$trees)
  new_nodes <-
    merge_heap_nodes(other_nodes, list_reverse(min_node_nodes))
  new_min_value <- binomial_nodes_min_value(new_nodes)
  binomial_heap(new_min_value, new_nodes)
}
```

So in summery, we can implement a binomial heap with $O(1)$ `find_minimal` and $O(\\log n)$ `insert`, `merge` and `delete_minimal` worst case complexity. We can show, however, that `insert` actually runs in time $O(1)$ amortised by considering how the list of heap nodes behave compared to how many link operations we make. If you consider the original `insert_binomial_node` implementation, it is clear that we only recurse when we make a link operation, so the complexity of the function is the number of link operations plus one. You can think of each link operation as switching a one bit in the original heap list binary number to zero and the termination of the recurse as switching one zero bit to one. If we now think of switching a bit from zero to one as costing two credits instead of one, then such operations also pay for flipping them back to zero again in a later insertion. This analysis, however, is only valid if we consider the heap an ephemeral data structure---if we consider it a persistent data structure, nothing prevents us from spending the credits on the one bits more than once. The other $O(\\log n)$ worst-case operations are still $O(\\log n)$ when amortised.

Because of this, constructing binomial heaps is much more efficient than constructing leftist heaps, see [@fig:heap-construction-leftist-binomial-comparison]. When we divide the the time it takes to simply construct a heap of a given size by that size, we see that the binomial heap has a flat time curve while the leftist heap grows logarithmically, telling us that in practise, the running time to construct a binomial heap is $O(n)$ while the time to construct a leftist heap is $O(n \\log n)$. This justify the much more complex data structure that binomial heaps are compared to the leftist heap; at least when we don't need a persistent data structure. The amortised analysis only works when we treat the binomial heap ephemerally.

![Comparison of heap construction for leftist and binomial heaps when inserting one element at a time.](figures/heap-construction-leftist-binomial-comparison){#fig:heap-construction-leftist-binomial-comparison}

I should also stress that this benefit of using binomial heaps over leftist heaps is only relevant when we build heaps by inserting elements one at a time. If we use the algorithm that constructs heaps by iteratively merging larger and larger heaps, then both binomial and leftist heaps are constructed in linear time and the leftist heap has a smaller overhead, see [@fig:heap-construction-linear].

![Constructing heaps using the linear time algorithm.](figures/heap-construction-linear){#fig:heap-construction-linear}

## Splay heaps

A somewhat different approach to heaps is so-called *splay trees*. These are really search trees and have the search tree property---all values in a left subtree are smaller than the value in the root and all values in the right subtree are larger---rather than the heap property. Because they are search trees we will consider them in more detail in the next chapter, but here we will use them to implement a heap.

The structure for a splay tree is just the same as for a search tree, and we have already seen this structure in [Chapter @sec:immutable]. A search tree is defined recursively: it consists of a node with a value and a left and a right subtree that are also search trees. The invariant for search trees is the one mentioned above: the value in the node is larger than all values in the left subtree and smaller than all values in the right subtree. We can implement this structure thusly:

```{r, eval=FALSE}
splay_tree_node <- function(value, left = NULL, right = NULL) {
  list(left = left, value = value, right = right)
}
```

The structure we implemented in [Chapter @sec:immutable] used sentinel trees for empty trees. This was because we needed to do dispatch on generic methods on empty trees. For the splay heap we will implement now, we will not represent the heap as just a tree but wrap it in a structure that contains the tree and the minimal value in the heap, so as with binomial heaps we have a representation of empty heaps that doesn't rely on sentinels. Because of this, we will simply use `NULL` to represent empty trees.[^NULL_vs_sentinels] The structure for splay heaps, the creation of empty heaps, and the test for emptiness, is implemented like this:

```{r, eval=FALSE}
splay_heap <- function(min_value, splay_tree) {
  structure(list(min_value = min_value, tree = splay_tree),
            class = c("splay_heap", "heap"))
}

empty_splay_heap <- function() splay_heap(NA, NULL)
is_empty.splay_heap <- function(x) is.null(x$tree)
```

[^NULL_vs_sentinels]: Using `NULL` to represent empty trees is a very simple solution, but it does add some extra danger to working with the trees. In R, if you access a named value in a list that isn't actually in the list, you will get `NULL` back. This means, for example, that if you misspell a variable, say write `x$lfet` instead of `x$left`, you will not get any complained when running the code, but you will always get `NULL` instead of what the real left subtree might be. Interpreting the default value when you have made an error as a meaningful representation of an empty tree is risky. We have to be extra careful when we do it.

We explicitly store the minimal value in the heap so we can return it in constant time:

```{r, eval=FALSE}
find_minimal.splay_heap <- function(heap) {
  heap$min_value
}
```

To actually find the node with the minimal value in a search tree, we need to find the leftmost node in the tree. This is, by the search tree property, the smallest value. We can find this node just by recursing to the left until we reach a node where the left child is empty.

```{r, eval=FALSE}
splay_find_minimal_value <- function(tree) {
  if (is.null(tree)) NA
  else if (is.null(tree$left)) tree$value
  else splay_find_minimal_value(tree$left)
}
```

Here, we have a special case when the entire tree is empty---we use `NA` to represent the minimal value in that case. We should only hit this case if the entire heap is empty, though. Similar to finding the minimal value, we could find the maximum value by recursing to the right until the right subtree is empty.

This search takes time proportional to the depth of the tree. If we keep the tree balanced, then this would be $O(\\log n)$, but for splay trees we do not explicitly balance them. Instead, we blindly rearrange trees whenever we modify them.[^rearrange_modify_splay] Whenever we delete or insert values, we will do a kind of rebalancing that pulls the modified parts of the tree closer to the root.

[^rearrange_modify_splay]: For a full splay tree implementation, we will also modify trees when we search in them. For the heap variant, where we explicitly store the minimal value, we do not need to do this, so for the splay heap we only modify trees when we insert or remove from them.

We see some of this rearrangement in the code we use for deleting the smallest value in a tree. This value is the leftmost node in the tree, and a recursion that removes it has three cases: two basis cases that differ only in whether the leftmost node is the only left tree on the leftmost path or if it is the left tree of a left tree, and one recursive case, see [@fig:splay-heap-delete-min]. In the first basis case, we can only return the right subtree. In the second case, we also replace the leftmost node with its right subtree, so you can think of it as a special case. If we were just removing the leftmost tree, we wouldn't need this special case; we could just recurse to the left and use the result as the left subtree when returning from the recursion. The reason we need it is found in the recursive case. Here we need access to the root of a tree, its right subtree, its left subtree and that subtrees two children. We will call recursively on the left subtree's left subtree and then rotate the tree as sown in [@fig:splay-heap-delete-min]. It is this rotation that has the special case when $x$ is the minimal value in the tree that we handle as the second basis case.

![Three cases in the recursion to delete the minimal node in a splay heap. In the recursive case, the tree $a'$ refers to the result of calling recursively on tree $a$.](figures/splay-heap-delete-min){#fig:splay-heap-delete-min}

The code for deleting the minimal node in a splay tree is this:

```{r, eval=FALSE}
splay_delete_minimal_value <- function(tree) {
  if (is.null(tree$left)) {
    tree$right

  } else {
    a <- tree$left$left
    x <- tree$left$value
    b <- tree$left$right
    y <- tree$value
    c <- tree$right

    if (is.null(a))
      splay_tree_node(left = b, value = y, right = c)
    else
      splay_tree_node(
        left = splay_delete_minimal_value(a),
        value = x,
        right = splay_tree_node(left = b, value = y, right = c)
      )
  }
}
```

The rotations we perform on the tree as we delete the minimal value does not balance the tree, but it does shorten the leftmost path. All nodes on the existing leftmost path will end up at half the depth they were at before the call. The nodes in tree $b$ will either get one node closer to the root or remain at their original depth, and nodes in tree $c$ will either remain at their current depth or increase their depth by one node. We are not balancing the tree but we are making the search path for the smallest value shorter on average, and it can be shown that we end up with an amortised $O(\\log n)$ running time per `delete_minimal` operation if we use this approach.^[Proving this is mostly an exercise in arithmetic and I will not repeat this analysis here. If you are interested, you can check @okasaki1999purely or any text book describing splay trees.]

To delete the minimal value in the splay heap, we need to delete it from the underlying splay tree and then update the stored minimal value. We can implement this operation this way:

```{r, eval=FALSE}
delete_minimal.splay_heap <- function(heap) {
  if (is_empty(heap))
    stop("Can't delete the minimal value in an empty heap")
  new_tree <- splay_delete_minimal_value(heap$tree)
  new_min_value <- splay_find_minimal_value(new_tree)
  splay_heap(min_value = new_min_value, splay_tree = new_tree)
}
```

When inserting a new element into a splay tree, we always put it at the root. To ensure the search tree property, we then have to put all elements smaller than the new value into the left subtree and all elements larger into the right subtree. To do this, we have a function, `partition` that collects all the smaller and all the larger elements than a "pivot" element and return them as splay trees. These "smaller" and "larger" trees are computed recursively based on the value in the current node and its left or right subtree. By looking at these two values, we can identify the subtree we need to recurse on to partition deeper parts of the tree, see [@fig:splay-heap-partition]. In the figure, $S(x)$ denotes the "smaller" tree we get by recursing on tree $x$ and $L(x)$ denotes the "larger" tree we get by recursing on $x$.

![Cases for splay heap partitioning (the special case where the tree is empty is left out).](figures/splay-heap-partition){#fig:splay-heap-partition}

The implementation of `partition` is not particularly elegant, but it just considers the case of an empty tree first and then each of the six cases from [@fig:splay-heap-partition] in turn:

```{r, eval=FALSE}
partition <- function(pivot, tree) {
  if (is.null(tree)) {
    smaller <- NULL
    larger <- NULL

  } else {
    a <- tree$left
    x <- tree$value
    b <- tree$right
    if (x <= pivot) {
      if (is.null(b)) {
        smaller <- tree
        larger <- NULL
      } else {
        b1 <- b$left
        y <- b$value
        b2 <- b$right
        if (y <= pivot) {
          part <- partition(pivot, b2)
          smaller <- splay_tree_node(
            left = splay_tree_node(
              left = a,
              value = x,
              right = b1
            ),
            value = y,
            right = part$smaller
          )
          larger <- part$larger
        } else {
          part <- partition(pivot, b1)
          smaller <- splay_tree_node(
            left = a,
            value = x,
            right = part$smaller
          )
          larger <- splay_tree_node(
            left = part$larger,
            value = y,
            right = b2
          )
        }
      }
    } else {
      if (is.null(a)) {
        smaller <- NULL
        larger <- tree
      } else {
        a1 <- a$left
        y <- a$value
        a2 <- a$right
        if (y <= pivot) {
          part <- partition(pivot, a2)
          smaller <- splay_tree_node(
            left = a1, 
            value = y, 
            right = part$smaller
          )
          larger <- splay_tree_node(
            left = part$larger,
            value = x, 
            right = b
          )
        } else {
          part <- partition(pivot, a1)
          smaller <- part$smaller
          larger <- splay_tree_node(
            left = part$larger, 
            value = y,
            right = splay_tree_node(
              left = a2,
              value = x,
              right = b
            )
          )
        }
      }
    }
  }
  list(smaller = smaller, larger = larger)
}
```

It is, unfortunately, not that unusual to have such long and inelegant functions for matching different cases in data structure manipulations. The cases themselves are not terribly complicated---we recognise a given shape of the tree and then we transform it into another shape---but implementing the tests and transformations can be very cumbersome and error prone.

```{r, eval=FALSE}
insert.splay_heap <- function(x, elm, ...) {
  part <- partition(elm, x$tree)
  new_tree <- splay_tree_node(value = elm, left = part$smaller, right = part$larger)
  new_min_value <- min(x$min_value, elm, na.rm = TRUE)
  splay_heap(min_value = new_min_value, splay_tree = new_tree)
}
```

```{r, eval=FALSE}
merge_splay_trees <- function(x, y) {
  if (is.null(x)) return(y)
  if (is.null(y)) return(x)

  a <- x$left
  val <- x$value
  b <- x$right

  part <- partition(val, y)
  splay_tree_node(left = merge_splay_trees(part$smaller, a),
                  value = val,
                  right = merge_splay_trees(part$larger, b))
}
```

```{r, eval=FALSE}
merge.splay_heap <- function(x, y, ...) {
  if (is_empty(x)) return(y)
  if (is_empty(y)) return(x)

  new_tree <- merge_splay_trees(x$tree, y$tree)
  new_min_value <- min(x$min_value, y$min_value, na.rm = TRUE)
  splay_heap(min_value = new_min_value, splay_tree = new_tree)
}
```


see [@fig:heap-construction-binomial-splay-comparison].

see [@fig:heap-construction-linear-splay-leftist].

![Constructing splay heaps one element at a time.](figures/heap-construction-binomial-splay-comparison){#fig:heap-construction-binomial-splay-comparison}

![Constructing splay heaps by iteratively merging heaps.](figures/heap-construction-linear-splay-leftist){#fig:heap-construction-linear-splay-leftist}

![Constructing splay heaps one element at a time for different types of input.](figures/splay-heap-construction-element-wise){#fig:splay-heap-construction-element-wise}

![Constructing splay heaps by iteratively merging for different types of input.](figures/splay-heap-construction-iterative){#fig:splay-heap-construction-iterative}

## Brodal heaps



