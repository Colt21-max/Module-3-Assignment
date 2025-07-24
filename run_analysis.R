
library(dplyr)
library(tidyr)

if(!file.exists("./rawdata")) {
  dir.create("./rawdata")
}
source <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(source, destfile = "./rawdata/projectdata.zip")

unzip(zipfile = "./rawdata/projectdata.zip", exdir = "./rawdata")

x_train <- read.table("./rawdata/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./rawdata/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./rawdata/UCI HAR Dataset/train/subject_train.txt")

x_test <- read.table("./rawdata/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./rawdata/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./rawdata/UCI HAR Dataset/test/subject_test.txt")

features <- read.table("./rawdata/UCI HAR Dataset/features.txt")

activity_labels <- read.table("./rawdata/UCI HAR Dataset/activity_labels.txt")

colnames(activity_labels) <- c("activity_ID", "activity_name")

colnames(x_train) <- features[, 2]
colnames(y_train) <- "activity_ID"
colnames(subject_train) <- "subject_ID"

colnames(x_test) <- features[, 2]
colnames(y_test) <- "activity_ID"
colnames(subject_test) <- "subject_ID"

train <- cbind(y_train, subject_train, x_train)
test <- cbind(y_test, subject_test, x_test)
fulldata <- rbind(train, test)

mean_sd <- grepl("activity_ID|subject_ID|mean\\(\\)|std\\(\\)", colnames(fulldata))
MeanandSD <- fulldata[, mean_sd]

ActivityNames <- merge(MeanandSD, activity_labels, by = "activity_ID", all.x = TRUE)

colnames(ActivityNames) <- gsub("^t", "time", colnames(ActivityNames))
colnames(ActivityNames) <- gsub("^f", "frequency", colnames(ActivityNames))
colnames(ActivityNames) <- gsub("Acc", "Accelerometer", colnames(ActivityNames))
colnames(ActivityNames) <- gsub("Gyro", "Gyroscope", colnames(ActivityNames))
colnames(ActivityNames) <- gsub("Mag", "Magnitude", colnames(ActivityNames))
colnames(ActivityNames) <- gsub("BodyBody", "Body", colnames(ActivityNames))

Final <- ActivityNames %>%
  group_by(subject_ID, activity_ID, activity_name) %>%
  summarise_all(mean)

write.table(Final, "Final.txt", row.names = FALSE)
