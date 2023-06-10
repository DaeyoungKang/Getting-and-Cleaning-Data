### Step 0. Package loading, working directory setting
library(utils); library(dplyr) 
workingDirectory <- "/Users/gd/Library/CloudStorage/Dropbox/DataScience/03GettingAndCleaningData/Course/UCI HAR Dataset"
setwd(workingDirectory)

### Step 1. Merges the training and the test sets to create one data set.
filePaths <- list.files(recursive=TRUE, full.names=TRUE) 
filePaths <- filePaths[c(14,16,15,5:13,26,28,27,17:25)]

dataList <- lapply(filePaths, read.table)

columnNames <- gsub("(.*)/", "", gsub("_test.txt", "", gsub("_train.txt", "", filePaths)))
for(i in 1:24){
  if(i==1|i==13){
    names(dataList[[i]]) <- "subject"
  }else if(i==2|i==14){
    names(dataList[[i]]) <- "activity"
  }else if(i==3|i==15){
    names(dataList[[i]]) <- read.table("features.txt")[,2]
  }else{
    names(dataList[[i]]) <- paste0(columnNames[i], c(1:128))
  }
}

for (j in 1:12){
  if(j == 1){
    dataTest <- dataList[[1]] 
    dataTrain <- dataList[[13]]
  }else{
    dataTest <- cbind(dataTest, dataList[[j]]) 
    dataTrain <- cbind(dataTrain, dataList[[j+12]])
    }
}

dataMerge <- rbind(dataTest, dataTrain)

### Step 2. Extracts only the measurements on the mean and standard deviation for each measurement.
columnsHaveMeanStd <- c(grep("mean()", names(dataMerge)), grep("std()", names(dataMerge)))
dataMeanStd <- dataMerge[, c(1, 2, columnsHaveMeanStd)] 

### Step 3. Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table("activity_labels.txt")$V2
for(i in 1:6){dataMeanStd$activity <- gsub(i, activityLabels[i], dataMeanStd$activity)}
head(dataMeanStd$activity, 50)

### Step 4. Appropriately labels the data set with descriptive variable names.

### Step 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject. #####
dataTidy <- group_by(dataMeanStd, subject, activity) %>%
  summarise_at(names(dataMeanStd)[-(1:2)], mean)

### Export tidy data
write.csv(dataTidy, "/Users/gd/Library/CloudStorage/Dropbox/DataScience/03GettingAndCleaningData/Course/dataTidy.csv")
