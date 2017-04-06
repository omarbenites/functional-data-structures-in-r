library(tibble)
library(microbenchmark)

get_performance_n <- function(
  algo
  , n
  , setup
  , evaluate
  , times
  , ...) {
  
  config <- setup(n)
  benchmarks <- microbenchmark(evaluate(n, config), times = times)
  tibble(algo = algo, n = n, time = benchmarks$time / 1e9) # time in sec
}

get_performance <- function(
  algo
  , ns
  , setup
  , evaluate
  , times = 10
  , ...) {
  f <- function(n) 
    get_performance_n(algo, n, setup, evaluate, times = times, ...)
  results <- Map(f, ns)
  do.call('rbind', results)
}


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
ggsave("set-comparison-member-div-n.pdf", width = 15, height = 10, units = "cm")
ggsave("set-comparison-member-div-n.png", width = 15, height = 10, units = "cm")
