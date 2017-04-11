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


setup <- function(empty) function(n) empty
evaluate <- function(n, empty) {
  set <- empty
  elements <- sample(1:n)
  for (elm in elements) {
    set <- insert(set, elm)
  }
}


ns <- seq(1000, 5000, by = 500)
performance <- rbind(get_performance("list()", ns, setup(empty_list_set()), evaluate),
                     get_performance("linked list", ns, setup(empty_linked_list_set()), evaluate))


library(ggplot2)

ggplot(performance, aes(x = as.factor(n), y = time, fill = algo)) +
  geom_boxplot() + 
  scale_fill_grey("Data structure") +
  xlab(quote(n)) + ylab("Time (sec)") + theme_minimal()
ggsave("set-comparison-direct.pdf", width = 12, height = 8, units = "cm")
ggsave("set-comparison-direct.png", width = 12, height = 8, units = "cm")

ggplot(performance, aes(x = as.factor(n), y = time / n, fill = algo)) +
  geom_boxplot() + 
  scale_fill_grey("Data structure") + #scale_color_discrete() +
  xlab(quote(n)) + ylab("Time / n") + theme_minimal()
ggsave("set-comparison-div-n.pdf", width = 12, height = 8, units = "cm")
ggsave("set-comparison-div-n.png", width = 12, height = 8, units = "cm")


ggplot(performance, aes(x = as.factor(n), y = time / n**2, fill = algo)) +
  geom_boxplot() + 
  scale_fill_grey("Data structure") + #scale_color_discrete() +
  xlab(quote(n)) + ylab(expression(Time / n**2)) + theme_minimal()
ggsave("set-comparison-div-n-squared.pdf", width = 12, height = 8, units = "cm")
ggsave("set-comparison-div-n-squared.png", width = 12, height = 8, units = "cm")


setup <- function(empty) function(n) {
  set <- empty
  elements <- sample(1:n)
  for (elm in elements) {
    set <- insert(set, elm)
  }
  set
}
evaluate <- function(n, set) {
  member(set, sample(n, size = 1))
}



ns <- seq(10000, 50000, by = 10000)
performance <- rbind(get_performance("linked list", ns, setup(empty_linked_list_set()), evaluate),
                     get_performance("list()", ns, setup(empty_list_set()), evaluate))


ggplot(performance, aes(x = as.factor(n), y = time / n, fill = algo)) +
  geom_boxplot() + 
  scale_fill_grey("Data structure") + 
  xlab(quote(n)) + ylab("Time / n") + theme_minimal()
ggsave("set-comparison-member-div-n.pdf", width = 12, height = 8, units = "cm")
ggsave("set-comparison-member-div-n.png", width = 12, height = 8, units = "cm")
