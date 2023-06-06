##### Step 0. Package loading, working directory setting #####
library(utils) #required to execute "read.table" function
library(dplyr) #required to execute "group_by", "summarise" functions
workingDirectory <- "/Users/gd/Library/CloudStorage/Dropbox/DataScience/03GettingAndCleaningData/Course/UCI HAR Dataset" #it was set for my computer
setwd(workingDirectory)

##### Step 1. Merges the training and the test sets to create one data set. #####
filePaths <- list.files(pattern="*.txt", recursive=TRUE, full.names=TRUE) 
# I set "recursive = TRUE" since I want list all files in sub-directories of "UCI HAR Dataset".
# I set "full.names = TRUE" since I want to provide the 'filePaths' to read.table function.

filePaths <- filePaths[c(14,16,15,5:13,26,28,27,17:25)]
# I excluded the "activity_labels.txt", "features_info.txt", "features.txt", and "README.txt" from "filePaths" since I don't want to read them now.
# I reorder of columns in "filePaths" since I want to view in order of "subject", "y"(type of activity), "X"(features), and the others in "Inertial Signals" directory.

dataList <- lapply(filePaths, read.table)
# I used the "lapply" function to batch load text files.

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

# For descriptive variable names,
# I set variable name as "subject" for "subject_test.txt" and "y_test.txt"
# I set variable name as "activity" for "y_test.txt" and "y_train.txt"
# I set variable names using "features.txt" for "X_test.txt" or "X_train.txt"
#   since "features.txt" seems to indicate the variable name of "X_test.txt" or "X_train.txt".
#   the column number of "X_test.txt" and "X_train.txt" was 561, which was same to the row number of "features.txt"
# I cannot find the variable names for dataframes in "Inertial Signals" directory 
#   so I set variable names by numbering pasting number after their file names.
# I used "for" loop to naming variable names.

for (j in 1:12){
  if(j == 1){
    dataTest <- dataList[[1]] 
    dataTrain <- dataList[[13]]
  }else{
    dataTest <- cbind(dataTest, dataList[[j]]) 
    dataTrain <- cbind(dataTrain, dataList[[j+12]])
    }
}
# "dataList" comprised of Test data ([[1]] to [[12]]) and Train data ([[13]] to [[24]]).
# So I first tried to bind columns of Test data and Train data respectively using "for" loop.

dataMerge <- rbind(dataTest, dataTrain)
# Then second, I bind rows of Test data and Train data.

##### Step 2. Extracts only the measurements on the mean and standard deviation for each measurement. #####
columnMeanStd <- c(grep("mean", names(dataMerge)), grep("std", names(dataMerge)))
# I tried to list columns regarding "mean" or "standart deviation". 
# As the "standard deviation" was abbreviated in column names, 
# I list named "columnMeanStd" using "grep()" function which find string "mean" or "std". 

dataMeanStd <- dataMerge[, c(1, 2, columnMeanStd)] 
# In addition to "columnMeanStd", I included "subject", "activity" columns in new dataframe named "dataMeanStd".

##### Step 3. Uses descriptive activity names to name the activities in the data set #####
activityLabels <- read.table("activity_labels.txt")$V2
for(i in 1:6){dataMeanStd$activity <- gsub(i, activityLabels[i], dataMeanStd$activity)}
head(dataMeanStd$activity, 50)
# The activity corresponding to the number 1 to 6 was listed in second column of "activity_labels.txt".
# I combined of "for" loop and "gsub()" function to replace the number to full activity name.

##### Step 4. Appropriately labels the data set with descriptive variable names. #####
# I tried to label variable names before completely merging the training and test sets in Step 1.

##### Step 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject. #####
dataTidy <- group_by(dataMeanStd, subject, activity) %>%
  summarise_at(names(dataMeanStd)[-(1:2)], mean)
# I used "group_by" and "summarise_at" function in "dplyr" package.

