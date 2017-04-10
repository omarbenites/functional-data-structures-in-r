
is_empty <- function(x) UseMethod("is_empty")

list_cons <- function(elem, lst)
  structure(list(item = elem, tail = lst), class = "linked_list")

list_nil <- list_cons(NA, NULL)
is_empty.linked_list <- function(x) identical(x, list_nil)
empty_list <- function() list_nil

list_head <- function(lst) lst$item
list_tail <- function(lst) lst$tail

list_reverse_helper <- function(lst, acc) {
  if (is_empty(lst)) acc
  else list_reverse_helper(list_tail(lst),
                           list_cons(list_head(lst), acc))
}
list_reverse_rec <- function(lst) 
  list_reverse_helper(lst, empty_list())
  
list_reverse_loop <- function(lst) {
  acc <- empty_list()
  while (!is_empty(lst)) {
    acc <- list_cons(list_head(lst), acc)
    lst <- list_tail(lst)
  }
  acc
}

setup <- function(n) {
  lst <- empty_list()
  elements <- sample(1:n)
  for (elm in elements) {
    lst <- list_cons(elm, lst)
  }
  lst
}
evaluate_rec <- function(n, lst) {
  list_reverse_rec(lst)
}
evaluate_loop <- function(n, lst) {
  list_reverse_loop(lst)
}


#ns <- seq(100, 500, by = 50)
#performance <- rbind(get_performance("recursive", ns, setup, evaluate_rec),
#                     get_performance("loop", ns, setup, evaluate_loop))

library(ggplot2)
#ggplot(performance, aes(x = as.factor(n), y = time / n, fill = algo)) +
#  geom_boxplot() + 
#  scale_fill_grey("Data structure") + 
#  xlab(quote(n)) + ylab("Time / n") + theme_minimal()
#ggsave("list-reverse-comparison.pdf", width = 12, height = 8, units = "cm")


list_concatenate <- function(l1, l2) {
  if (is_empty(l1)) l2
  else list_cons(list_head(l1), list_concatenate(list_tail(l1), l2))
}

list_concatenate_loop <- function(l1, l2) {
  rev_l1 <- empty_list()
  while (!is_empty(l1)) {
    rev_l1 <- list_cons(list_head(l1), rev_l1)
    l1 <- list_tail(l1)
  }
  result <- l2
  while (!is_empty(rev_l1)) {
    result <- list_cons(list_head(rev_l1), result)
    rev_l1 <- list_tail(rev_l1)
  }
  result
}

setup <- function(n) {
  lst <- empty_list()
  elements <- sample(1:n)
  for (elm in elements) {
    lst <- list_cons(elm, lst)
  }
  lst
}
evaluate_rec <- function(n, lst) {
  list_concatenate(lst, lst)
}
evaluate_loop <- function(n, lst) {
  list_concatenate_loop(lst, lst)
}


ns <- seq(100, 500, by = 50)
performance <- rbind(get_performance("recursive", ns, setup, evaluate_rec),
                     get_performance("loop", ns, setup, evaluate_loop))

library(ggplot2)
ggplot(performance, aes(x = as.factor(n), y = time / n, fill = algo)) +
  geom_boxplot() + 
  scale_fill_grey("Data structure") + 
  xlab(quote(n)) + ylab("Time / n") + theme_minimal()
ggsave("list-concatenate-comparison.pdf", width = 12, height = 8, units = "cm")
ggsave("list-concatenate-comparison.png", width = 12, height = 8, units = "cm")

