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
