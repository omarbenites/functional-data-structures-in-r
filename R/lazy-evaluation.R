
nil <- function() NULL
cons <- function(car, cdr) {
  force(car)
  force(cdr)
  function() list(car = car, cdr = cdr)
}

is_nil <- function(lst) is.null(lst())
car <- function(lst) lst()$car
cdr <- function(lst) lst()$cdr


cat <- function(l1, l2) {
  print("cat")
  force(l1)
  print("force l2")
  force(l2)
  if (is_nil(l1)) l2
  else {
    lazy_thunk <- function(lst) function() { print("invoking cat"); lst() }
    lazy_thunk(cons(car(l1), cat(cdr(l1), l2)))
  }
}

reverse <- function(lst) { 
  print("reverse")
  do_reverse <- function(lst) {
    print("do_reverse")
    result <- nil
    while (!is_nil(lst)) {
      result <- cons(car(lst), result)
      lst <- cdr(lst) 
    }
    result
  }
  force(lst)
  lazy_thunk <- function(lst) function() lst()
  lazy_thunk(do_reverse(lst))
}

lazy_queue <- function(front, back, front_length, back_length) { 
  structure(list(front = front, back = back,
                 front_length = front_length,
                 back_length = back_length),
            class = "lazy_queue")
}

make_q <- function(front, back, front_length, back_length) { 
  if (back_length <= front_length)
    lazy_queue(front, back, front_length, back_length) 
  else
    lazy_queue(cat(front, reverse(back)), nil, front_length + back_length, 0)
}

#' Creates an empty lazy queue
#' @export
empty_lazy_queue <- function() lazy_queue(nil, nil, 0, 0)

#' @method is_empty lazy_queue
#' @export
is_empty.lazy_queue <- function(x) is_nil(x$front) && is_nil(x$back)

#' @method enqueue lazy_queue
#' @export
enqueue.lazy_queue <- function(x, elm)
  make_q(x$front, cons(elm, x$back), x$front_length, x$back_length + 1)

#' @method front lazy_queue
#' @export
front.lazy_queue <- function(x) car(x$front)

#' @method dequeue lazy_queue
#' @export
dequeue.lazy_queue <- function(x)
  make_q(cdr(x$front), x$back, x$front_length - 1, x$back_length)



q <- empty_lazy_queue()
q <- enqueue(q, 1)
q <- enqueue(q, 2)
q <- enqueue(q, 3)
q <- enqueue(q, 4)
q <- enqueue(q, 5)
q <- enqueue(q, 6)

