insert <- function(set, elem) UseMethod("insert")
member <- function(set, elem) UseMethod("member")

empty_list_set <- function() {
  structure(c(), class = "list_set")
}

insert.list_set <- function(set, elem) {
  structure(c(elem, set), class = "list_set")
}

member.list_set <- function(set, elem) {
  elem %in% set
}

s <- empty_list_set()
member(s, 1)
s <- insert(s, 1)
member(s, 1)

is_empty <- function(x) UseMethod("is_empty")


linked_list_cons <- function(head, tail) {
  structure(list(head = head, tail = tail), 
            class = "linked_list_set")
}

linked_list_nil <- linked_list_cons(NA, NULL)
empty_linked_list_set <- function() linked_list_nil
is_empty.linked_list_set <- function(x) identical(x, linked_list_nil)

insert.linked_list_set <- function(set, elem) {
  linked_list_cons(elem, set)
}

member.linked_list_set <- function(set, elem) {
  while (!is_empty(set)) {
    if (set$head == elem) return(TRUE)
    set <- set$tail
  }
  return(FALSE)
}

s <- empty_linked_list_set()
member(s, 1)
s <- insert(s, 1)
member(s, 1)
s <- insert(s, 2)
member(s, 2)


construct_random_set <- function(n, empty_set) {
  set <- empty_set
  permutation <- sample(1:n)
  for (elm in permutation) 
    set <- insert(set, elm)
  set
}

library(microbenchmark)
xx <- microbenchmark(construct_random_set(10, empty_list_set()))
