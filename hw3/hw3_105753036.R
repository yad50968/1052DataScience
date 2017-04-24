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
  return (2 * precision * recall / (precision + recall))
}

calauc <- function(predscore, ref) {
  eval <- prediction(predscore, ref)
  auc <- attributes(performance(eval, 'auc'))$y.values[[1]]
  return (auc)
}

getSecondIndex <- function(x) {
  return (which(x == sort(x,partial=length(x)-1)[length(x)-1]))
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
files_name <- c()

for(file in files) {
  method <- gsub(".csv", "", basename(file))
  d <- read.table(file, header = T, sep = ",")

  # cal all function
  f1  <- round(calf1(d$prediction, d$reference, query_m), digit=2)
  auc <- round(calauc(d$pred.score, d$reference), digit=2)
  sensitivity <- round(calSensitivity(d$prediction, d$reference, query_m), digit = 2)
  specificity <- round(calSpecificity(d$prediction, d$reference, query_m), digit = 2)

  f1 <- replace(f1, is.nan(f1), 0)
  auc <- replace(auc, is.nan(auc), 0)
  sensitivity <- replace(sensitivity, is.nan(sensitivity), 0)
  specificity <- replace(specificity, is.nan(specificity), 0)
  
  # add result to vector
  files_name <- c(files_name, file)
  methods <- c(methods, method)
  f1Result <- c(f1Result, f1)
  aucResult <- c(aucResult, auc)
  sensitivityResult <- c(sensitivityResult, sensitivity)
  specificityResult <- c(specificityResult, specificity)
}

out_data <- data.frame(method = methods, sensitivity = sensitivityResult, specificity = specificityResult, F1 = f1Result, AUC = aucResult, stringsAsFactors = F)
index <- apply(out_data[,-1], 2, which.max) 


output_methods <- methods[index]


#only consider method > 1 and F1
if(length(out_data$method) > 1) {

  sec_F1_index <- getSecondIndex(out_data$F1)
  best_file <- read.table(files_name[index[3]], header = T, sep = ",")
  best_zero_one <- ifelse(best_file$prediction == best_file$reference, 1, 0)

  second_file <- read.table(files_name[sec_F1_index], header = T, sep = ",")
  second_zero_one <- ifelse(second_file$prediction == second_file$reference, 1, 0)

  d <- rbind(
      data.frame(group='A', value=best_zero_one),
      data.frame(group='B', value=second_zero_one)
  )
  contingency_table <- table(d)

  if(fisher.test(contingency_table)$p.value < 0.05) {
    output_methods[3] <- paste0(methods[index[3]], "*")
  }
} else {
  sec_F1_index <- index[3]
}


# output file
out_data <- rbind(out_data, c("highest", output_methods))
write.table(out_data, file = out_f, sep = ",", row.names = F, quote = F)
