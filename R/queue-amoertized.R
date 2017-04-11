
func <- c("",
          "enqueue", "enqueue", "enqueue", 
          "front", "dequeue", "front", "dequeue", 
          "enqueue", "enqueue", "enqueue", "enqueue", 
          "front", "dequeue", "front", "dequeue", "front", "dequeue")
operation <- (1:length(func)) - 1
time_spent <- cumsum(c(0, 1, 1, 1,
                4, 1, 1, 1,
                1, 1, 1, 1,
                1, 1, 5, 1, 1, 1))
banked <- c(0, 1, 2, 3, 
            0, 0, 0, 0,
            1, 2, 3, 4,
            4, 4, 0, 0, 0, 0)

d <- data_frame(operation = operation, time_spent = time_spent, banked = banked,
                bound = 2 * operation)
ggplot(d) +
  geom_line(aes(x = operation, y = bound), linetype = "dotted") + 
  geom_line(aes(x = operation, y = time_spent), linetype = "solid") + 
  geom_line(aes(x = operation, y = time_spent + banked), linetype = "dashed") +
  geom_point(aes(x = operation, y = time_spent)) +
  geom_text(aes(x = operation, y = time_spent, label = func), 
            hjust = 0, nudge_x = 0.2, nudge_y = -0.2) +
  scale_y_continuous(breaks = time_spent, limits = c(0, 27)) +
  scale_x_continuous(breaks = operation, limits = c(0, 20)) + 
  xlab("Iteration") + ylab("Operation count") +
  theme_minimal()
ggsave("queue-amortized-linear-bound.pdf", width = 12, height = 10, units = "cm")
ggsave("queue-amortized-linear-bound.png", width = 12, height = 10, units = "cm")

