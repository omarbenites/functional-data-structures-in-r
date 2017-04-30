# Heaps {#sec:heaps}

Heaps, or priority queues, are collections of elements from an ordered set where, besides checking for emptiness and inserting elements

```r
is_empty <- function(x) UseMethod("is_empty")
insert <- function(x, elm) UseMethod("insert")
```

we can also access and delete the smallest element.^[I will implement all the heaps in this chapter to have access to the minimal element. It is a trivial modification to have access to the largest instead.]

```r
find_minimal <- function(heap) UseMethod("find_minimal")
delete_minimal <- function(heap) UseMethod("delete_minimal")
```

Heaps are not necessarily sets. It is possible for heaps to have multiple elements with the same value.

In addition to these operations, we will also require that we can merge two heaps.

```r
merge <- function(x, y) UseMethod("merge")
```

In many of the implementations, we have use for this merge function, and we can always implement a default version like this:

```r
merge.default <- function(x, y) {
  while (!is_empty(y)) {
    x <- insert(x, find_minimal(y))
    y <- delete_minimal(y)
  }
  x
}
```

Since we already used `merge` with bags, though, we probably shouldn't make this default implementation of the generic function. Instead, we can make a version for heaps

```r
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

```r
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

```r
vector_to_heap <- function(empty_heap, vec) {
  heap <- empty_heap
  for (e in vec)
    heap <- insert(heap, e)
  heap
}
```

With the `vector_to_heap` and `heap_to_list` functions, we can sort elements thus:  

```r
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

```r
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

```r
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

```r
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

```r
empty_leftist_heap_node <- leftist_heap_node(NA, NULL, NULL)
empty_leftist_heap <- function() empty_leftist_heap_node
is_empty.leftist_heap <- function(x)
  identical(x, empty_leftist_heap_node)
```

Since a leftist heap has the heap property, we can always get the the minimal value from the root of the tree:

```r
find_minimal.leftist_heap <- function(heap) {
  heap$value
}
```

To delete the minimal value, we need to get rid of the value in the root. But since the two sub-trees of the root are heaps, we can create a new heap with the minimal value removed just by merging the two sub-trees.

```r
delete_minimal.leftist_heap <- function(heap) {
  merge(heap$left, heap$right)
}
```

Inserting an element is equally simple: we can make a singleton heap and merge it into the existing heap.

```r
insert.leftist_heap <- function(x, elm) {
  merge(x, leftist_heap_node(elm))
}
```

All the complexity of a leftist heap boils down to the `merge` operation. This is where we will exploit that the right sub-tree is never more than half the heap. If we merge two heaps, we take the minimal value in the root and put the left part of the first tree as the left sub-tree and then merge recursively on the right. Since this cuts the problem down to half the size, we will never spend more time than $O(\\log n)$.

```r
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

## Splay heaps

## Brodal heaps



