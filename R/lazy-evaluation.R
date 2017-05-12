
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

l1 <- cons(1, cons(2, cons(3, nil)))
l2 <- cons(4, cons(5, cons(6, nil)))

x <- cat(l1, reverse(l2))
car(x)
x <- cdr(x)
x <- cdr(x)
x <- cdr(x)
x <- cdr(x)
