#devtools::install_github("mailund/ralgo")
library(ralgo)
library(microbenchmark)
library(tibble)
library(ggplot2)

setup <- function(n) n
evaluate <- function(empty) function(n, x) {
  elements <- 1:n
  queue <- empty
  for (elm in elements) {
    queue <- enqueue(queue, elm)
  }
  for (i in seq_along(elements)) {
    queue <- dequeue(queue)
  }
}

ns <- seq(5000, 10000, by = 1000)
performance <- rbind(get_performance("explicit environment", ns, setup, evaluate(empty_env_queue())),
                     get_performance("closure environment", ns, setup, evaluate(empty_closure_queue())),
                     get_performance("functional queue", ns, setup, evaluate(empty_extended_queue())))

ggplot(performance, aes(x = as.factor(n), y = time / n, fill = algo)) +
  geom_boxplot() + 
  scale_fill_grey("Data structure") + 
  xlab(quote(n)) + ylab(expression(Time / n)) + theme_minimal()
ggsave("queue-comparisons.pdf", width = 12, height = 8, units = "cm")
ggsave("queue-comparisons.png", width = 12, height = 8, units = "cm")




#ns <- seq(50, 100, by = 10)
#get_performance("functional queue", ns, setup, evaluate(empty_extended_queue()))

ns <- seq(5000, 10000, by = 1000)
performance <- rbind(get_performance("explicit environment", ns, setup, evaluate(empty_env_queue())),
                     get_performance("lazy queue", ns, setup, evaluate(empty_lazy_queue())))

ggplot(performance, aes(x = as.factor(n), y = time / n, fill = algo)) +
  geom_boxplot() + 
  scale_fill_grey("Data structure") + 
  xlab(quote(n)) + ylab(expression(Time / n)) + theme_minimal()
ggsave("lazy-worstcase-queue-comparisons.pdf", width = 12, height = 8, units = "cm")
ggsave("lazy-worstcase-queue-comparisons.png", width = 12, height = 8, units = "cm")






