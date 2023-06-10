# Getting-and-Cleaning-Data
This file explains codes for Course Project in "Getting and Cleaning Data" Course in Coursera.


### Package loading and working directory setting
-------------
```
library(utils); library(dplyr)
workingDirectory <- "/Users/gd/Library/CloudStorage/Dropbox/DataScience/03GettingAndCleaningData/Course/UCI HAR Dataset"
setwd(workingDirectory)
```
* The required packages are `utils` for `read.table()` function and `dplyr` for `group_by()` and `summarize()` functions.  
* Working directory was set up for my convenience and it can be changed according to the user's path of "UCI HAR Dataset" directory.

### Step 1. Merges the training and the test sets to create one data set.
-------------
```
filePaths <- list.files(recursive=TRUE, full.names=TRUE)
filePaths <- filePaths[c(14,16,15,5:13,26,28,27,17:25)]
```
* I set `recursive = TRUE` and `full.names = TRUE` to list all files in sub-directories of "UCI HAR Dataset" and provide the file names with paths to `read.table()` function, respectively. 
* However, files in working base such as "activity_labels.txt", "features.info.txt", "features.txt", and "README.txt" were excluded as they were not necessary to be included. In addition, the order of the list was rearranged.
```
dataList <- lapply(filePaths, read.table)
```
I used the "lapply" function to batch load text files.
```
columnNames <- gsub("(.*)/", "", gsub("_test.txt", "", gsub("_train.txt", "", filePaths)))
```
Although the labeling the data set with descriptive variable name is step 4, 
I decide to label the the training and test sets before fully merging them as it seems to be simpler.
```
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
```
For descriptive variable names,  
* I set variable name as `subject` for "subject_test.txt" and "y_test.txt" and `activity` for "y_test.txt" and "y_train.txt", respectively. 
* I set variable names using "features.txt" for data from "X_test.txt" and "X_train.txt" 
since "features.txt" seems to indicate the variable name of "X_test.txt" or "X_train.txt"  
considering the column number of "X_test.txt" and "X_train.txt" was equal to the row number of "features.txt", 561.  
* In case of data from "Inertial Signals" directory", I cannot find the variable names. So I set variable names by pasting a number from 1 to 128 after their file names.  
* I used `for` loop to naming aforementioned variable names.

```
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
```
The `dataList` comprised of Test data `dataList([[1]]:[[12]])` and Train data `dataList([[13]]:[[24]])`.
So I first tried to bind all variables of the Test data and the Train data in listed files using `for` loop and `cbind()` function.
Then I merged Test and Train data using `rbind()` function. The `dataMerge` is the result of the Step 1.

### Step 2. Extracts only the measurements on the mean and standard deviation for each measurement.
-------------
```
columnsHaveMeanStd <- c(grep("mean()", names(dataMerge)), grep("std()", names(dataMerge)))
```
* The list of columns columns containing "mean" or "std" (abbreviation of standard deviation) using `grep()` function.
```
dataMeanStd <- dataMerge[, c(1, 2, columnsHaveMeanStd)] 
```
* In addition to `columnMeanStd`, I included `subject`, `activity` columns in new dataframe named `dataMeanStd`, which is the result of the Step 2.

### Step 3. Uses descriptive activity names to name the activities in the data set.
-------------
```
activityLabels <- read.table("activity_labels.txt")$V2
for(i in 1:6){dataMeanStd$activity <- gsub(i, activityLabels[i], dataMeanStd$activity)}
head(dataMeanStd$activity, 50)
```
* The activity description corresponding to the number 1 to 6 was listed in second column of "activity_labels.txt".
* I combined of `for` loop and `gsub()` function to replace the number with activity description.
* You can see the description of activity when you execute `head(dataMeanStd$activity, 50)`.

### Step 4. Appropriately labels the data set with descriptive variable names.
-------------
I labeled variable names before completely merging the training and test sets in Step 1.
Therefore, the `dataMeanStd` is the result of the Step 4. 

### Step 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
-------------
```
dataTidy <- group_by(dataMeanStd, subject, activity) %>%
  summarise_at(names(dataMeanStd)[-(1:2)], mean)
```
* I used `group_by()` and `summarise_at()` functions in `dplyr` package.
* `dataTidy` is result of the Step 5, which is uploaded dataTidy.txt in Coursera. 
