library(reshape2)

filename <- "getdata_dataset.zip"

#Descargamos la tabla con la info a utilizar#

if(!file.exists(filename))
	{
		fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
		download.file(fileUrl, filename, method = "auto")
	}

if(!file.exists("UCI HAR Dataset"))
	{
		unzip(filename)
	}
acLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")

acLabels[,2] <- as.character(acLabels[,2])
features[,2] <- as.character(features[,2])

fW <- grep(".*mean.*|.*std.*", features[,2])
fW.names <- features[fW,2]
fW.names <- gsub('-mean', 'Mean', fW.names)
fW.names <- gsub('-std', 'STD', fW.names)
fW.names <- gsub('[-()]', '', fW.names)

train <- read.table("UCI HAR Dataset/train/X_train.txt")[fW]
trainA <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainS <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainS, trainA, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[fW]
testA <- read.table("UCI HAR Dataset/test/Y_test.txt")
testS <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testS, testA, test)

allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", fW.names)

allData$activity <- factor(allData$activity, levels = acLabels[,1], labels = acLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
