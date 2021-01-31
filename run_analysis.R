getwd()
setwd("D:\\Business Analytics\\Caursera\\3. Getting & Cleaning Data\\R_Code\\Assignment")

# Download the file and put the file in the database folder

if(!file.exists("./database")){dir.create("./database")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./database/Data.zip",method="curl")

# Unzip the file

unzip(zipfile="./database/data.zip",exdir="./database")

# Get the list of files which are available in the folder 'UCI HAR Dataset'

path <- file.path("./database" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)
files

# Read data from the files into the variables

activityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
activityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)
subjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
subjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)
featuresTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
featuresTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

# Merges the training and the test sets to create one data set
# Concatenate the data tables by rows

subject <- rbind(subjectTrain, subjectTest)
activity<- rbind(activityTrain, activityTest)
features<- rbind(featuresTrain, featuresTest)

# set names to variables

names(subject)<-c("subject")
names(activity)<- c("activity")

featuresNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(features)<- featuresNames$V2

# Merge columns to get the data frame Data for all data

dataCombine <- cbind(subject, activity)
data <- cbind(features, dataCombine)



# Extracts only the measurements on the mean and standard deviation for each measurement
# Subset Name of Features by measurements on the mean and standard deviation

subfeaturesNames<-featuresNames$V2[grep("mean\\(\\)|std\\(\\)", featuresNames$V2)]

# Subset the data frame Data by seleted names of Features
selectedNames <- c(as.character(subfeaturesNames), "subject", "activity" )
data <- subset(data,select=selectedNames)

# Check the structures of the data frame Data
str(data)

# Uses descriptive activity names to name the activities in the data set
# Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)

# facorize Variale activity in the data frame Data using descriptive activity names & check
head(data$activity,30)

# Appropriately labels the data set with descriptive variable names
#prefix t is replaced by time
#Gyro is replaced by Gyroscope
# prefix f is replaced by frequency
# Mag is replaced by Magnitude
# BodyBody is replaced by Body

names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))

names(data)

# Creates a second,independent tidy data set and ouput it
Data2<-aggregate(. ~subject + activity, data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)




