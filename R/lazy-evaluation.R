
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
  force(l1)
  force(l2)
  if (is_nil(l1)) l2
  else {
    lazy_thunk <- function(lst) function() lst()
    lazy_thunk(cons(car(l1), cat(cdr(l1), l2)))
  }
}


rot <- function(front, back, a) {
  print("rot")
  force(a)
  if (is_nil(front)) cons(car(back), a)
  else {
    lazy_thunk <- function(lst) function() { print("eval"); lst() }
    lazy_thunk(cons(car(front), rot(cdr(front), cdr(back), cons(car(back), a))))
  }
}

lazy_queue <- function(front, back, helper) {
  structure(list(front = front, back = back, helper = helper),
            class = "lazy_queue")
}


make_q <- function(front, back, helper) {
  if (is_nil(helper)) {
    helper <- rot(front, back, nil)
    lazy_queue(helper, nil, helper)
  } else {
    lazy_queue(front, back, cdr(helper))
  }
}

#' Creates an empty lazy queue
#' @export
empty_lazy_queue <- function() lazy_queue(nil, nil, nil)

#' @method is_empty lazy_queue
#' @export
is_empty.lazy_queue <- function(x) is_nil(x$front) && is_nil(x$back)

#' @method enqueue lazy_queue
#' @export
enqueue.lazy_queue <- function(x, elm)
  make_q(x$front, cons(elm, x$back), x$helper)

#' @method front lazy_queue
#' @export
front.lazy_queue <- function(x) car(x$front)

#' @method dequeue lazy_queue
#' @export
dequeue.lazy_queue <- function(x)
  make_q(cdr(x$front), x$back, x$helper)



q <- empty_lazy_queue()
q <- enqueue(q, 1)
q <- enqueue(q, 2)
q <- enqueue(q, 3)
q <- enqueue(q, 4)
q <- enqueue(q, 5)
q <- enqueue(q, 6)

eval(substitute(substitute(x,environment(q$front)),list(x=body(q$front))))
eval(substitute(substitute(x,environment(q$back)),list(x=body(q$back))))

q <- enqueue(q, 7)
front(q)

q <- dequeue(q)
q <- dequeue(q)

eval(substitute(substitute(x,environment(q$front)),list(x=body(q$front))))
