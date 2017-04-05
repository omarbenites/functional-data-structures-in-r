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


empty_linked_list_set <- function() {
  structure(c(), class = "linked_list_set")
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
