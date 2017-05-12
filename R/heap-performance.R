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
#                      get_performance("binomial", ns, setup, evaluate(empty_binomial_heap())))

ggplot(performance, aes(x = as.factor(n/1000), y = time / n, fill = algo)) +
  geom_boxplot() + 
  scale_fill_grey("Data structure") + 
  xlab("n (thousands)") + ylab(expression(Time / n)) + theme_minimal()
ggsave("heap-construction-leftist-binomial-comparison.pdf", width = 12, height = 8, units = "cm")
ggsave("heap-construction-leftist-binomial-comparison.png", width = 12, height = 8, units = "cm")
