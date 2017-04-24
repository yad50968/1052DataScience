library('ROCR')

calConfusionMatrix <- function(pred, ref, target) {
  tandf = c(pred == ref)
  pandn = c(pred == target)
  confusionmatrix <- table(truth = tandf, prediction = pandn)
  return (confusionmatrix)
}

calSensitivity <- function(pred, ref, target) {
  confusionmatrix <- calConfusionMatrix(pred, ref, target)
  return (confusionmatrix[4] / (confusionmatrix[4] + confusionmatrix[1]))
}

calSpecificity <- function(pred, ref, target) {
  confusionmatrix <- calConfusionMatrix(pred, ref, target)
  return (confusionmatrix[2] / (confusionmatrix[2] + confusionmatrix[3]))
}
calPrecision <- function(pred, ref, target) {
  confusionmatrix <- calConfusionMatrix(pred, ref, target)
  return (confusionmatrix[4] / (confusionmatrix[4] + confusionmatrix[3]))
}

calf1 <- function(pred, ref, target) {
  precision = calPrecision(pred, ref, target)
  recall = calSensitivity(pred, ref, target)
  print(2 * precision * recall / (precision + recall))
  return (2 * precision * recall / (precision + recall))
}

calauc <- function(predscore, ref) {
  eval <- prediction(predscore, ref)
  auc <- attributes(performance(eval, 'auc'))$y.values[[1]]
  return (auc)
}

# read parameters
args = commandArgs(trailingOnly=TRUE)
if (length(args) == 0) {
  stop("USAGE: Rscript hw2_105753036.R --target male|female --files file1 file2 ... filen --out out.csv", call.=FALSE)
}

# parse parameters
i <- 1 
while(i < length(args)) {
  if(args[i] == "--target") {
    query_m <- args[i+1]
    i <- i+1
  } else if(args[i] == "--files") {
    j <- grep("-", c(args[(i+1):length(args)], "-"))[1]
    files <- args[(i+1):(i+j-1)]
    i <- i+j-1
  } else if(args[i] == "--out") {
    out_f <- args[i+1]
    i <- i+1
  } else {
    stop(paste("Unknown flag", args[i]), call.=FALSE)
  }
  i <- i+1
}

print("PROCESS")
print(paste("query mode :", query_m))
print(paste("output file:", out_f))
print(paste("files      :", files))

# read files
methods <- c()
f1Result <- c()
aucResult <- c()
sensitivityResult <- c()
specificityResult <- c()

for(file in files) {
  method <- gsub(".csv", "", basename(file))
  d <- read.table(file, header = T, sep = ",")

  # cal all function
  f1  <- round(calf1(d$prediction, d$reference, query_m), digit=2)
  auc <- round(calauc(d$pred.score, d$reference), digit=2)
  sensitivity <- round(calSensitivity(d$prediction, d$reference, query_m), digit = 2)
  specificity <- round(calSpecificity(d$prediction, d$reference, query_m), digit = 2)

  # add result to vector
  methods <- c(methods, method)
  f1Result <- c(f1Result, f1)
  aucResult <- c(aucResult, auc)
  sensitivityResult <- c(sensitivityResult, sensitivity)
  specificityResult <- c(specificityResult, specificity)
}

out_data <- data.frame(method = methods, sensitivity = sensitivityResult, specificity = specificityResult, F1 = f1Result, AUC = aucResult, stringsAsFactors = F)
index <- apply(out_data[,-1], 2, which.max) 

# output file
out_data <- rbind(out_data, c("highest", methods[index]))
write.table(out_data, file = out_f, sep = ",", row.names = F, quote = F)
