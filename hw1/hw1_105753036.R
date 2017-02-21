args<-commandArgs(TRUE)
inputNameWithOutExtension <- sub('\\.csv$', '', args[1])
outputName <- args[2]
inputName <- args[1]

data <-read.table(inputName, header = TRUE, sep = ",", colClasses = c("NULL",NA,NA,"NULL"))

colMax <- function(data) apply(data, 1, max, na.rm = TRUE)
maxW <- round(colMax(t(data$weight)), 2)
maxH <- round(colMax(t(data$height)), 2)

outputData = data.frame(set = inputNameWithOutExtension, weight = maxW, height = maxH)
write.csv(outputData, file = outputName, row.names = FALSE)
