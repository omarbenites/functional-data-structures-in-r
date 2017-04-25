
nil <- function() NULL
cons <- function(car, cdr) {
  force(car)
  force(cdr)
  function() list(car = car, cdr = cdr)
}

is_nil <- function(lst) is.null(lst())
car <- function(lst) lst()$car
cdr <- function(lst) lst()$cdr


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
  lazy_thunk <- function(lst) {
    function() lst()
  }
  lazy_thunk(do_cat(l1, l2))
}


vector_to_list <- function(v) {
  lst <- nil
  for (x in v) lst <- cons(x, lst)
  reverse(lst)
}

l1 <- vector_to_list(1:10000)
l2 <- vector_to_list(1:10000)

library(microbenchmark)
microbenchmark(lst <- cat(l1, l2), times = 1) # fast operation
microbenchmark(car(lst), times = 1) # slow operation -- needs to copy l1
microbenchmark(car(lst), times = 1) # fast operation

microbenchmark(lst <- cat(l1, reverse(l2)), times = 1) # fast operation
microbenchmark(car(lst), times = 1) # slow operation -- needs to copy l1
microbenchmark(car(lst), times = 1) # fast operation

microbenchmark(lst <- cat(l1, reverse(l2)), times = 1) # fast operation
microbenchmark(car(lst), times = 1) # slow operation -- needs to copy l1
microbenchmark(car(lst), times = 1) # fast operation
microbenchmark(length(lst), times = 1) # slow operation -- needs to reverse l2
microbenchmark(length(lst), times = 1) # faster operation

microbenchmark(length(cat(l1, l2)), times = 1) # faster operation
