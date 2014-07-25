library(reshape2)

# data source
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

# download and unzip data into 'UCI HAR Dataset' directory
download.file(url, 'UCI_HAR_Dataset.zip', 'curl')
unzip('UCI_HAR_Dataset.zip')

# move to the new directory and read in the raw data in the appropriate format
pwd <- setwd('UCI HAR Dataset')
activity_labels <- scan(file = 'activity_labels.txt', what = character())
activity_labels <- activity_labels[seq(2, length(activity_labels), 2)]

features <- scan(file = 'features.txt', what = character())
features <- features[seq(2, length(features), 2)]

test_data <- read.table('test/X_test.txt', header = FALSE, col.names = features)
test_subject <- scan(file = 'test/subject_test.txt', what = numeric())
test_activity <- scan(file = 'test/y_test.txt', what = numeric())
test_activity <- factor(test_activity, labels = activity_labels)

train_data <- read.table('train/X_train.txt', header = FALSE, col.names = features)
train_subject <- scan(file = 'train/subject_train.txt', what = numeric())
train_activity <- scan(file = 'train/y_train.txt', what = numeric())
train_activity <- factor(train_activity, labels = activity_labels)

# bind subject and activity vectors to each dataset
test_data <- cbind(subject = test_subject, test_data)
test_data <- cbind(test_data, activity = test_activity)

train_data <- cbind(subject = train_subject, train_data)
train_data <- cbind(train_data, activity = train_activity)

# merge and sort datasets
dataset <- rbind(test_data, train_data)
dataset <- dataset[order(dataset$subject),]

# extract only mean and standard deviation for each measurement
columns <- sort(union(grep('mean()', names(dataset)), grep('std()', names(dataset))))
columns <- sort(union(columns, c(1,563))) # include subject and activity columns
dataset <- dataset[,columns]

# melt data and cast it to a dataframe orderby by subject, then activity
meltdata <- melt(dataset, id=c('subject', 'activity'))
means_matrix <- acast(meltdata, subject ~ variable ~ activity, mean)

means_data <- dcast(meltdata, subject + activity ~ variable, mean)

# export tidy dataset to .txt file
setwd(pwd)
write.table(means_data, 'tidy_data.txt')


