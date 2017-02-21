args<-commandArgs(TRUE)  # get the args
inputName <- args[1]
inputNameWithOutExtension <- sub('\\.csv$', '', inputName)  # remove filename extension
outputName <- args[2]


data <-read.table(inputName, header = TRUE, sep = ",", colClasses = c("NULL",NA,NA,"NULL")) 
# read input data only for height and weight

colMax <- function(data) apply(data, 1, max, na.rm = TRUE)
# function for get the max value for column
  
maxW <- round(colMax(t(data$weight)), 2)
maxH <- round(colMax(t(data$height)), 2)
# let factor only two bits

outputData = data.frame(set = inputNameWithOutExtension, weight = maxW, height = maxH)
write.csv(outputData, file = outputName, row.names = FALSE)
# output data
