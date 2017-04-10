library(ralgo)

st_member_fast <- function(x, elm, candidate = NA) {
  if (is_empty(x)) return(!is.na(candidate) && elm == candidate)
  if (elm < x$value) st_member_fast(x$left, elm, candidate)
  else st_member_fast(x$right, elm, x$value)
}

st_member_slow <- function(x, elm) {
  if (is_empty(x)) return(FALSE)
  if (x$value == elm) return(TRUE)
  if (elm < x$value) st_member_slow(x$left, elm)
  else st_member_slow(x$right, elm)
}

setup <- function(n) {
  elements <- sample(1:n)
  tree <- empty_search_tree()
  for (elm in elements) {
    tree <- insert(tree, elm)
  }
  tree
}
evaluate_slow <- function(n, set) {
  st_member_slow(set, sample(n, size = 1))
}
evaluate_fast <- function(n, set) {
  st_member_fast(set, sample(n, size = 1))
}

#ns <- seq(5000, 10000, by = 1000)
#performance <- rbind(get_performance("slow member", ns, setup, evaluate_slow),
#                     get_performance("fast_member", ns, setup, evaluate_fast))

#ggplot(performance, aes(x = as.factor(n), y = time / log(n), fill = algo)) +
#  geom_boxplot() + 
#  scale_fill_grey("Data structure") + 
#  xlab(quote(n)) + ylab("Time / log(n)") + theme_minimal()
#ggsave("search-tree-member-comparison.pdf", width = 12, height = 8, units = "cm")
#ggsave("search-tree-member-comparison.png", width = 12, height = 8, units = "cm")


setup <- function(n) n
setup <- function(n) {
  elements <- sample(1:n)
  tree <- empty_search_tree()
  for (elm in elements) {
    tree <- insert(tree, elm)
  }
  tree
}
evaluate_slow <- function(n, x) {
  elements <- 1:n
  tree <- empty_search_tree()
  for (elm in elements) {
    tree <- insert(tree, elm)
  }
  tree
}
evaluate_fast <- function(n, x) {
  elements <- sample(1:n)
  tree <- empty_search_tree()
  for (elm in elements) {
    tree <- insert(tree, elm)
  }
  tree
}

ns <- seq(10, 100, by = 10)
performance <- rbind(get_performance("increasing order", ns, setup, evaluate_slow),
                     get_performance("random_order", ns, setup, evaluate_fast))

ggplot(performance, aes(x = as.factor(n), y = time / n**2, fill = algo)) +
  geom_boxplot() + 
  scale_fill_grey("Data structure") + 
  xlab(quote(n)) + ylab(expression(Time / n**2)) + theme_minimal()
ggsave("search-tree-construction-comparison.pdf", width = 12, height = 8, units = "cm")
ggsave("search-tree-construction-comparison.png", width = 12, height = 8, units = "cm")
