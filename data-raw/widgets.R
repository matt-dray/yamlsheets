set.seed(1066)

n <- 10

widgets <- data.frame(
  location = LETTERS[1:n],
  region = c(rep("north", n / 2), rep("south", n / 2)),
  count = ceiling(runif(n) * 100)
)

widgets_north <- subset(widgets, region == "north", select = -region)
widgets_south <- subset(widgets, region == "south", select = -region)

write.csv(widgets, "inst/extdata/widgets.csv", row.names = FALSE)
write.csv(widgets_north, "inst/extdata/widgets_north.csv", row.names = FALSE)
write.csv(widgets_south, "inst/extdata/widgets_south.csv", row.names = FALSE)
