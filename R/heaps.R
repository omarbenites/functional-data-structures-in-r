x <- empty_leftist_heap()
x <- insert(x, 3)
x <- insert(x, 2)
x <- insert(x, 5)

y <- empty_leftist_heap()
y <- insert(y, 3)
y <- insert(y, 1)
y <- insert(y, 4)

merge.default <- function(x, y) {
  while (!is_empty(y)) {
    x <- insert(x, find_minimal(y))
    y <- delete_minimal(y)
  }
  x
}

z <- merge.default(x, y)

vector_to_heap <- function(empty_heap, vec) {
  heap <- empty_heap
  for (e in vec)
    heap <- insert(heap, e)
  heap
}

heap_to_list <- function(x) {
  l <- empty_list()
  while (!is_empty(x)) {
    l <- list_cons(find_minimal(x), l)
    x <- delete_minimal(x)
  }
  l
}
heap_to_vector <- function(x) {
  as.vector(heap_to_list(x), mode = class(find_minimal(x)))
}

heap_sort <- function(vec, empty_heap) {
  heap <- vector_to_heap(empty_heap, vec)
  lst <- heap_to_list(heap)
  list_reverse(lst)
}
as.vector(heap_sort(sample(1:10), empty_leftist_heap()), "integer")


 
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

heap_sort <- function(vec, empty_heap, empty_queue) {
  heap <- vector_to_heap(vec, empty_heap, empty_queue)
  lst <- heap_to_list(heap)
  list_reverse(lst)
}

as.vector(heap_sort(sample(1:10), empty_leftist_heap(), empty_env_queue()), "integer")
