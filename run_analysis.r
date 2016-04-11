# Loading of necessary packages for script and setting user path.

getPackages <- c("data.table", "reshape2")
sapply(getPackages, require, character.only = TRUE)
userPath <- getwd()

# Assuming user has downloaded the data and is in proper working directory containing folder "UCI HAR Dataset". Set "dataPath" to read pertinent project files. 

dataPath <- file.path(userPath, "UCI HAR Dataset") 

# Reading subject files.
tablePatientTrain <- fread(file.path(dataPath, "train", "subject_train.txt"))
tablePatientTest <- fread(file.path(dataPath, "test", "subject_test.txt"))
# Reading activity files.
tableActivityTrain <- fread(file.path(dataPath, "train", "Y_train.txt"))
tableActivityTest <- fread(file.path(dataPath, "test", "Y_test.txt"))
# Reading data files.
tableDataTrain <- fread(file.path(dataPath, "train", "X_train.txt"))
tableDataTest <- fread(file.path(dataPath, "test", "X_test.txt"))

# Merging tables.

tablePatient <- rbind(tablePatientTrain, tablePatientTest) 
tableActivity <- rbind(tableActivityTrain, tableActivityTest)
setnames(tablePatient, "V1", "personID")
setnames(tableActivity, "V1", "activityType")
tableData <- rbind(tableDataTrain, tableDataTest)

# Merging above tables into one.

mergeTablePatientActivity <- cbind(tablePatient, tableActivity)
mergeTableAllData <- cbind(mergeTablePatientActivity, tableData)
setkey(mergeTableAllData, personID, activityType)

# Reading features.txt file and extracting mean and std.

tableFeatures <- fread(file.path(dataPath, "features.txt"))
setnames(tableFeatures, names(tableFeatures), c("featNum", "featDescription"))
tableFeatures <- tableFeatures[grepl("mean\\(\\)|std\\(\\)", featDescription)]

# Matching featNum column values to variable names in mergeTableAllData

tableFeatures$featureMatchCol <- tableFeatures[, paste0("V", featNum)]
# Subsetting in "mergeTableAllData" only the columns prescribed from above step, from tableFeatures$MatchCol
variableSubset <- c(key(mergeTableAllData), tableFeatures$featureMatchCol)
mergeTableAllData <- mergeTableAllData[, variableSubset, with=FALSE]

# Extracting activity names from "activity_labels.txt" and apply it to "mergeTableAllData".

tableActivityType <- fread(file.path(dataPath, "activity_labels.txt"))
setnames(tableActivityType, names(tableActivityType), c("activityType", "activityName"))
mergeTableAllData <- merge(mergeTableAllData, tableActivityType, by = "activityType", all.x = TRUE)

# Melt "mergeTableAllData" to values in its column names, except keeping what is set in our key to still be columns. Then merge the activity description and number from "tableFeatures" to "mergeTableAllData".

setkey(mergeTableAllData, personID, activityType, activityName)
mergeTableAllData <- melt(mergeTableAllData, key(mergeTableAllData), variable.name = "featureMatchCol")
mergeTableAllData <- merge(mergeTableAllData, tableFeatures[, list(featNum, featureMatchCol, featDescription)], by="featureMatchCol", all.x=TRUE)

mergeTableAllData$activity <- factor(mergeTableAllData$activityName)
mergeTableAllData$feature <- factor(mergeTableAllData$featDescription)

# Using regular expressions to filter features from "mergeTableAllData$feature" so as to add columns of features to "mergeTableAllData".

grephelp <- function (regex) {
        grepl(regex, mergeTableAllData$feature)
}
discrepancyValue <- 2
w <- matrix(seq(1, discrepancyValue), nrow = discrepancyValue)
s <- matrix(c(grephelp("^t"), grephelp("^f")), ncol = nrow(w))
mergeTableAllData$featureDomain <- factor(s %*% w, labels = c("Time", "Frequency"))
s <- matrix(c(grephelp("BodyAcc"), grephelp("Gravity")), ncol = nrow(w))
mergeTableAllData$featureAccelerationType <- factor(s %*% w, labels = c(NA, "Body", "Gravity"))
s <- matrix(c(grephelp("Acc"), grephelp("Gyr")), ncol = nrow(w))
mergeTableAllData$featureTool <- factor(s %*% w, labels = c("Accelerometer", "Gyroscope"))
s <- matrix(c(grephelp("mean()"), grephelp("std()")), ncol = nrow(w))
mergeTableAllData$featureMeasurementType <- factor(s %*% w, labels = c("Mean", "SD"))
mergeTableAllData$featureMagnitude <- factor(grephelp("Mag"), labels = c(NA, "Magnitude"))
mergeTableAllData$featureJerk <- factor(grephelp("Jerk"), labels = c(NA, "Jerk"))
discrepancyValue <- 3
w <- matrix(seq(1, discrepancyValue), nrow = discrepancyValue)
s <- matrix(c(grephelp("-X"), grephelp("-Y"), grephelp("-Z")), ncol = nrow(w))
mergeTableAllData$featureAxis <- factor(s %*% w, labels = c(NA, "X", "Y", "Z"))

# Creating the tidy data set.

setkey(mergeTableAllData, personID, activity, featureDomain, featureTool, featureAccelerationType, featureAxis, featureMagnitude, featureJerk, featureMeasurementType)
tableTidy <- mergeTableAllData[, list(avg = mean(value)), by = key(mergeTableAllData)]











