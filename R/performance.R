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


