library(ralgo)
library(microbenchmark)
library(tibble)
library(ggplot2)

setup <- function(n) n
evaluate <- function(empty) function(n, x) {
  elements <- 1:n
  heap <- empty
  for (elm in elements) {
    heap <- insert(heap, elm)
  }
}

# ns <- seq(1000, 10000, by = 1000)
# performance <- rbind(get_performance("leftist", ns, setup, evaluate(empty_leftist_heap())),
#                      get_performance("splay", ns, setup, evaluate(empty_splay_heap())),
#                      get_performance("binomial", ns, setup, evaluate(empty_binomial_heap())))
# 
# ggplot(performance %>% filter(algo != "leftist"), aes(x = as.factor(n/1000), y = time / n, fill = algo)) +
#   geom_boxplot() +
#   scale_fill_grey("Data structure") +
#   xlab("n (thousands)") + ylab(expression(Time / n)) + theme_minimal()
# ggsave("heap-construction-binomial-splay-comparison.pdf", width = 12, height = 8, units = "cm")
# ggsave("heap-construction-binomial-splay-comparison.png", width = 12, height = 8, units = "cm")


setup <- function(n) n
evaluate <- function(empty) function(n, x) {
  vector_to_heap(1:n, empty)
}

# ns <- seq(1000, 20000, by = 2000)
# performance <- rbind(get_performance("leftist", ns, setup, evaluate(empty_leftist_heap())),
#                      get_performance("splay", ns, setup, evaluate(empty_splay_heap())))
#                      #get_performance("binomial", ns, setup, evaluate(empty_binomial_heap())))
# 
# ggplot(performance %>% filter(algo != "binomial"), aes(x = as.factor(n/1000), y = time / n, fill = algo)) +
#   geom_boxplot() + 
#   scale_fill_grey("Data structure") + 
#   xlab("n (thousands)") + ylab(expression(Time / n)) + theme_minimal()
# ggsave("heap-construction-linear-splay-leftist.pdf", width = 12, height = 8, units = "cm")
# ggsave("heap-construction-linear-splay-leftist.png", width = 12, height = 8, units = "cm")



setup_sorted <- function(n) 1:n
setup_reversed <- function(n) rev(1:n)
setup_random <- function(n) sample(1:n)
evaluate <- function(empty) function(n, x) {
  vector_to_heap(x, empty)
}

# ns <- seq(1000, 15000, by = 1000)
# performance <- rbind(get_performance("sorted", ns, setup_sorted, evaluate(empty_splay_heap())),
#                      get_performance("reversed", ns, setup_reversed, evaluate(empty_splay_heap())),
#                      get_performance("random", ns, setup_random, evaluate(empty_splay_heap())))
# 
# ggplot(performance, aes(x = as.factor(n/1000), y = time / n, fill = algo)) +
#   geom_boxplot() + 
#   scale_fill_grey("Input sequence") + 
#   xlab("n (thousands)") + ylab(expression(Time / n)) + theme_minimal()
# ggsave("splay-heap-construction-iterative.pdf", width = 12, height = 8, units = "cm")
# ggsave("splay-heap-construction-iterative.png", width = 12, height = 8, units = "cm")

evaluate <- function(empty) function(n, x) {
  heap <- empty
  for (elm in x) {
    heap <- insert(heap, elm)
  }
}
ns <- seq(1000, 15000, by = 1000)
performance <- rbind(get_performance("sorted", ns, setup_sorted, evaluate(empty_splay_heap())),
                     get_performance("reversed", ns, setup_reversed, evaluate(empty_splay_heap())),
                     get_performance("random", ns, setup_random, evaluate(empty_splay_heap())))
ggplot(performance, aes(x = as.factor(n/1000), y = time / n, fill = algo)) +
  geom_boxplot() + 
  scale_fill_grey("Input sequence") + 
  xlab("n (thousands)") + ylab(expression(Time / n)) + theme_minimal()
ggsave("splay-heap-construction-element-wise.pdf", width = 12, height = 8, units = "cm")
ggsave("splay-heap-construction-element-wise.png", width = 12, height = 8, units = "cm")
