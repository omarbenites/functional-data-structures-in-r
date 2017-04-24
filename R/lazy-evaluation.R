lazy <- function(value) {
  function() value
}

f <- lazy((1:100000)[1])

library(microbenchmark)
microbenchmark(f(), times = 1)
microbenchmark(f(), times = 1)
microbenchmark(f(), times = 1)
microbenchmark(f(), times = 1)

list_cons <- function(elem, lst)
  structure(list(head = elem, tail = lst), class = "linked_list")

list_nil <- list_cons(NA, NULL)
empty_list <- function() list_nil
is_empty.linked_list <- function(x) identical(x, list_nil)


lazy_empty_list <- lazy(empty_list())
lazy_cons <- function(elm, lst) {
  lazy(list_cons(elm, lst()))
}

lst <- lazy_cons(2, lazy_empty_list)
lst()

lst <- lazy_cons(1, lazy_cons(2, lazy_empty_list))
lst()

lst <- lazy_cons(2, lazy_empty_list)
lst <- lazy_cons(1, lst)
lst()

