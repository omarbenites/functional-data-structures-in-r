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

Leftist heaps are a classical implementation of heaps based on one simple idea: You represent the heap as a binary tree with the heap property, and you make sure that the left sub-tree is always at least as large as the right sub-tree.^[My description of leftist heaps is based on @okasaki1999purely. The original description of the data structure can be found in @Crane:1972:LLP:906397.] The structure exploits a general trick in data structure design known as "the smaller half" trick. If you have to do some computation recursively, but you only have to do it for one of two children in a binary tree, you pick the smaller of the two trees. If you do this, you slice away half of the size of the tree in each recursive call.[^smaller_half] If you slice away half the data in each recursive call, you can never recurse deeper than the logarithm of the full data size. So, if we keep the left sub-tree at least as large as the right sub-tree, and always make sure that all operations on the heaps only recurse to the right, then we have a limit on how deep we can recurse. There is a variant of this called *maxiphopic heaps* [@Okasaki:2005:ATC:1047124.1047407] that makes this more explicit, but the underlying idea is the same; maxiphopic heaps just do not require that the larger sub-tree is the left tree.

[^smaller_half]: The "smaller half" name is an oxymoron. If we really split data in half, both half would be the same size. What we really mean is that we slice away at least one half of the data in each recursion. I didn't come up with the name, but that is the name I know the trick by.

To keep the invariant that the left sub-tree is always at least as large as the right sub-tree, we keep track of tree sizes. We call this the *rank* of the tree. The structure we use to represent a leftist heap looks like this:

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
                 rank = 0),
            class = c("leftist_heap", "heap"))
}
```

The class of the structure is `"leftist_heap"` and then `"heap"`, so the `vector_to_heap` function will work with this class.

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

```{r, eval=FALSE}
binomial_tree_node <- function(value, trees) {
  list(value = value, trees = trees)
}

link_binomial_trees <- function(t1, t2) {
  if (t1$value < t2$value) {
    binomial_tree_node(t1$value, list_cons(t2, t1$trees))
  } else {
    binomial_tree_node(t2$value, list_cons(t1, t2$trees))
  }
}

binomial_heap_node <- function(rank, tree) {
  list(rank = rank, tree = tree)
}

singleton_binomial_heap_node <- function(value) {
  tree <- binomial_tree_node(value, empty_list())
  binomial_heap_node(0, tree)
}

binomial_heap <- function(min_value, heap_nodes = empty_list()) {
  structure(list(min_value = min_value, heap_nodes = heap_nodes),
            class = c("binomial_heap", "heap"))
}

#' Construct an empty binomial heap
#' @return an empty binomial heap
#' @export
empty_binomial_heap <- function() binomial_heap(NA)

#' Test whether a binomial heap is empty
#' @param x binomial heap
#' @return Whether the heap is empty
#' @method is_empty binomial_heap
#' @export
is_empty.binomial_heap <- function(x) is_empty(x$heap_nodes)

#' @method find_minimal binomial_heap
#' @export
find_minimal.binomial_heap <- function(heap) {
  if (is_empty(heap)) stop("Can't get the minimal value in an empty heap")
  heap$min_value
}

# The trees in a binomial heaps are ordered by rank and should be thought of as
# one bits in a binary number. When we insert an element it sets the first bit to zero
# but if that bit is already set we must carry it so we create a new tree from the
# new tree and the former lowest rank tree and then carry that in a recursive call
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

#' @method insert binomial_heap
#' @export
insert.binomial_heap <- function(x, elm, ...) {
  if (is_empty(x)) {
    nodes <- list_cons(singleton_binomial_heap_node(elm), empty_list())
    binomial_heap(elm, nodes)
  } else {
    new_min_value <- min(find_minimal(x), elm)
    new_node <- singleton_binomial_heap_node(elm)
    new_nodes <- insert_binomial_node(new_node, x$heap_nodes)
    binomial_heap(new_min_value, new_nodes)
  }
}

# merging two lists of heap nodes work like binary addition...
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
    merge_heap_nodes(new_node, merge_heap_nodes(list_tail(x), list_tail(y)))
  }
}

#' @method merge binomial_heap
#' @export
merge.binomial_heap <- function(x, y, ...) {
  if (is_empty(x)) return(y)
  if (is_empty(y)) return(x)
  new_min_value <- min(find_minimal(x), find_minimal(y))
  new_nodes <- merge_heap_nodes(x$heap_nodes, y$heap_nodes)
  binomial_heap(new_min_value, new_nodes)
}

get_minimal_node <- function(min_value, heap_nodes) {
  # we should never reach an empty list since the min_value must be in there...
  first_node <- list_head(heap_nodes)
  if (first_node$tree$value == min_value) first_node
  else get_minimal_node(min_value, list_tail(heap_nodes))
}

delete_minimal_node <- function(min_value, heap_nodes) {
  # we should never reach an empty list since the min_value must be in there...
  first_node <- list_head(heap_nodes)
  if (first_node$tree$value == min_value) list_tail(heap_nodes)
  else list_cons(first_node, delete_minimal_node(min_value, list_tail(heap_nodes)))
}

binomial_trees_to_nodes <- function(rank, trees) {
  if (is_empty(trees)) {
    empty_list()
  } else {
    list_cons(binomial_heap_node(rank, list_head(trees)),
              binomial_trees_to_nodes(rank, list_tail(trees)))
  }
}

binomial_nodes_min_value <- function(heap_nodes, current_min = NA) {
  my_min <- function(x, y) ifelse(is.na(x), y, min(x, y))
  if (is_empty(heap_nodes)) {
    current_min
  } else {
    new_current_min <- my_min(current_min, list_head(heap_nodes)$tree$value)
    binomial_nodes_min_value(list_tail(heap_nodes), new_current_min)
  }
}

#' @method delete_minimal binomial_heap
#' @export
delete_minimal.binomial_heap <- function(heap) {
  if (is_empty(heap)) stop("Can't delete the minimal value in an empty heap")

  min_node <- get_minimal_node(heap$min_value, heap$heap_nodes)
  other_nodes <- delete_minimal_node(heap$min_value, heap$heap_nodes)
  min_node_nodes <- binomial_trees_to_nodes(min_node$rank - 1,
                                            list_reverse(min_node$tree$trees))
  new_nodes <- merge_heap_nodes(other_nodes, min_node_nodes)
  new_min_value <- binomial_nodes_min_value(new_nodes)
  binomial_heap(new_min_value, new_nodes)
}
```


## Splay heaps

## Brodal heaps



