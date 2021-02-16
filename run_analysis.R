# run_analysis.R script

# DATA

temp <- tempfile() #creates a temp empty file

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp) #downloads the zip into the temp file

unzip(temp, exdir="./data") #unzip the data

#Reads all data from test and train folders 


testset <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
testlabels <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
testsubjects <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

trainset <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
trainlabels <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
trainsubjects <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")


## Merges the training and the test datasets to create one.

alltest <- cbind(testlabels, testsubjects, testset) #binds all test datasets
alltrain <- cbind(trainlabels, trainsubjects, trainset) #binds all train datasets

traintest <- rbind(alltrain, alltest) #binds train and test

features <-  read.table("./data/UCI HAR Dataset/features.txt",header = FALSE) #reads feature table

colnames(traintest)[3:563] <- features [ ,2] #renames all the feature columns according to the feature data

colnames(traintest)[1]<- "activityid" #renames first column
colnames(traintest)[2]<- "subjects" #renames second column
colnames(traintest) #checks the names of the columns


## Extracts only the measurements on the mean and standard deviation for each measurement. 

colNames <- colnames(traintest) #stores the column names to easy access

colNames

means <- grep ("mean()", colNames) #takes the columns with mean
sds <- grep ("std()", colNames) # takesthe columns with sd

meansd <- cbind (traintest["activityid"], traintest["subjects"],  traintest[means], traintest[sds]) #dataframe only with means and sd

## Uses descriptive activity names to name the activities in the data set

activityLabels <-  read.table("./data/UCI HAR Dataset/activity_labels.txt", header = FALSE, stringsAsFactors = T)

colnames(activityLabels) <- c("activityid", "activitytype")

activitytype <- sub("_", " ", activityLabels$activitytype) #removes underscore from the activity names

activityLabels[,2] <- activitytype #replaces de activitytype column. Now the names are without underscore.

descriptive <- merge(meansd, activityLabels, by = "activityid", all.x = TRUE)

library(dplyr)

descriptive <- select(descriptive, last_col(), everything()) #moves the last column to the first position

activitytype <- strsplit(descriptive$activitytype, "_") #removes underscore from the names of the column

categories <- as.factor(unique(descriptive$activitytype)) #just to check if the names ar correct
categories


# Appropriately labels the data set with descriptive variable names.

# already named before (lines 32:38)

colnames(descriptive) <- tolower(names(descriptive)) # lowercase for column names


# From the data set in step 4, creates a second, independent tidy data set with the average
# of each variable for each activity and each subject.


tidy <- descriptive %>% 
  group_by(subjects, activitytype) %>%
  summarise_all(list(mean))

tidy <- tidy[, c(3,2,1, 4:82)] # reorder the columns to look better


#Save data 

write.table(tidy, "tidydata.txt", row.name=FALSE) #saves the data

