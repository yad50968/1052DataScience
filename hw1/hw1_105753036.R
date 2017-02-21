args<-commandArgs(TRUE)  # get the args
if (length(args) == 0) {
    stop("USAGE: Rscript hw1_105753036.R -files {input-file-name} -out {output-file-name")
}
i <- 1
while(i < length(args)) {
    if(args[i] == "-files") {
        inputName <- args[i+1]
        i <- i + 1
    } else if (args[i] == "-out") {
        outputName <- args[i+1]
        i <- i + 1
    } else {
        stop(paste("Unknown flag", args[i]), call.=FALSE)
    }
    i <- i + 1
}
inputNameWithOutExtension <- sub('\\.csv$', '', inputName)  # remove filename extension


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
