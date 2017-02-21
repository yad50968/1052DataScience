args<-commandArgs(TRUE)

data <-read.table(args[1], header = TRUE, sep = ",", colClasses = c("NULL",NA,NA,"NULL"))
inputName <- sub('\\.csv$', '', args[1])

colMax <- function(data) apply(data, 1, max, na.rm = TRUE)
maxW <- colMax(t(data$weight))
maxH <- colMax(t(data$height))
outputData = data.frame(set = inputName, weight = maxW, height = maxH)
write.csv(outputData, file = args[2], row.names = FALSE)
