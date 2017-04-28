
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
  if (is_nil(front)) cons(car(back), a)
  else {
    lazy_thunk <- function(lst) function() lst()
    tail <- cons(car(back), a)
    lazy_thunk(cons(car(front), rot(cdr(front), cdr(back), tail)))
  }
}

lazy_queue <- function(front, back, front_length, back_length) {
  structure(list(front = front, back = back, 
                 front_length = front_length, back_length = back_length),
            class = "lazy_queue")
}

make_q <- function(front, back, front_length, back_length) {
  if (back_length <= front_length)
    lazy_queue(front, back, front_length, back_length)
  else
    lazy_queue(rot(front, back, nil), nil, 
               front_length + back_length, 0)
}

empty_lazy_queue <- function() lazy_queue(nil, nil, 0, 0)
is_empty.lazy_queue <- function(x) is_nil(x$front) && is_nil(x$back)

enqueue.lazy_queue <- function(x, e) 
  make_q(x$front, cons(e, x$back),
         x$front_length, x$back_length + 1)

front.lazy_queue <- function(x) car(x$front)

dequeue.lazy_queue <- function(x) 
  make_q(cdr(x$front), x$back,
         x$front_length - 1, x$back_length)



q <- empty_lazy_queue()
for (x in 1:10000) {
  q <- enqueue(q, x)
}
for (i in 1:10000) {
  q <- dequeue(q)
}


v <- vector("integer", 10000)
for (i in 1:10000) {
  v[i] <- front(q)
  q <- dequeue(q)
}
#v

q <- empty_lazy_queue()
for (i in 1:10000) {
  q <- enqueue(q, i)
  q <- dequeue(q)
}

#v

